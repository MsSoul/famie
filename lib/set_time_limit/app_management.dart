// filename: app_management.dart (display sa apps in)
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../design/app_toggle_prompt.dart';
import '../services/app_toggle_service.dart';
import '../services/app_service.dart';
import '../algorithm/decision_tree.dart';
import '../design/app_time_prompt_dialog.dart';
import '../design/dialog_prompt.dart';

class AppManagement extends StatefulWidget {
  final String childId;
  final String parentId;

  const AppManagement({super.key, required this.childId, required this.parentId});

  @override
  AppManagementState createState() => AppManagementState();
}

class AppManagementState extends State<AppManagement> {
  List<Map<String, dynamic>> apps = [];
  bool isLoading = true;
  final Logger _logger = Logger('AppManagement');
  final AppService appService = AppService();
  final AppToggleService appToggleService = AppToggleService();

  @override
  void initState() {
    super.initState();
    fetchApps();
    showLoadingDialog();
  }

  @override
  void didUpdateWidget(covariant AppManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      fetchApps();
      showLoadingDialog();
    }
  }

  void showLoadingDialog() {
    DialogPrompt.showLoading(context);
  }

  void fetchApps() async {
    try {
      _logger.info("Fetching apps for childId: ${widget.childId} and parentId: ${widget.parentId}");

      await appService.syncAppManagement(widget.childId, widget.parentId);
      List<Map<String, dynamic>> fetchedApps = await appService.fetchAppManagement(widget.childId);

      setState(() {
        apps = fetchedApps;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _logger.severe("Error fetching apps from app_management", e);
    }
  }

  void toggleAllowedStatus(int index) async {
    bool isAllowed = apps[index]['is_allowed'] == true;
    bool newStatus = !isAllowed;

    AppDecision decision = AppDecision(
      isAllowed: newStatus,
      setTimeSchedule: newStatus == true,
    );

    String decisionResult = decision.makeDecision();
    _logger.info('Decision result: $decisionResult');

    if (decisionResult == 'Block App (Toggle OFF)') {
      setState(() {
        apps[index]['is_allowed'] = false;
      });

      await appToggleService.updateAppToggleStatus(
        apps[index]['package_name'] ?? '',
        false,
        widget.childId,
        widget.parentId,
      );
      _logger.info("App ${apps[index]['app_name'] ?? 'Unknown App'} blocked (is_allowed: false)");

    } else if (decisionResult == 'Allow App (No Time Schedule, Toggle ON)') {
      setState(() {
        apps[index]['is_allowed'] = true;
      });

      await appToggleService.updateAppToggleStatus(
        apps[index]['package_name'] ?? '',
        true,
        widget.childId,
        widget.parentId,
      );
      _logger.info("App ${apps[index]['app_name'] ?? 'Unknown App'} allowed (is_allowed: true)");

      // Automatically open the time scheduling prompt after toggling ON
      openAppTogglePrompt(apps[index]['_id'] ?? '', apps[index]['app_name'] ?? 'Unknown App');

    } else if (decisionResult == 'Set App Time Schedule Prompt') {
      setState(() {
        apps[index]['is_allowed'] = true;
      });

      await appToggleService.updateAppToggleStatus(
        apps[index]['package_name'] ?? '',
        true,
        widget.childId,
        widget.parentId,
      );
      _logger.info("App ${apps[index]['app_name'] ?? 'Unknown App'} allowed (is_allowed: true) with time schedule prompt");

      // Show the time scheduling prompt after updating the backend
      openAppTogglePrompt(apps[index]['_id'] ?? '', apps[index]['app_name'] ?? 'Unknown App');
    } else {
      _logger.warning('Unexpected decision result');
    }
  }

  void openAppTogglePrompt(String appId, String appName) {
    _logger.info('Opening AppTogglePrompt for $appName');
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AppTogglePrompt(
        appId: appId,
        childId: widget.childId,
        appName: appName,
      ),
    ).then((value) => _logger.info("AppTogglePrompt dialog closed"));
  }

  // New function to show the AppTimePromptDialog with opacity
  void showAppTimePromptDialog(BuildContext context, String appId, String childId, String appName) {
    _logger.info('Opening AppTimePromptDialog with opacity for $appName');
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3), // Adjust opacity as needed
      builder: (context) {
        return AppTimePromptDialog(
          appId: appId,
          childId: childId,
          appName: appName,
        );
      },
    ).then((value) => _logger.info("AppTimePromptDialog closed"));
  }

  // Update the method to use showAppTimePromptDialog
  void openAppTimePromptScreen(String appId, String appName) {
    showAppTimePromptDialog(context, appId, widget.childId, appName);
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle fontStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: appBarColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Center(
              child: Text(
                'Manage Child’s Apps',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : apps.isEmpty
                  ? const Center(child: Text("No apps found."))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: apps.length,
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    app['app_name'] ?? 'Unknown App',
                                    style: fontStyle,
                                  ),
                                ),
                                Switch(
                                  value: app['is_allowed'] == true,
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.green,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey[400],
                                  onChanged: (value) => toggleAllowedStatus(index),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.access_time,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    openAppTimePromptScreen(app['_id'] ?? '', app['app_name'] ?? 'Unknown App');
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}


/*mugana kaso ang schedule prompt dli mugawas
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../design/app_toggle_prompt.dart'; // Import AppTogglePrompt for toggling app
import '../services/app_toggle_service.dart'; // Import AppToggleService for posting to app_management
import '../services/app_service.dart'; // Import AppService for fetching from app_list
import '../algorithm/decision_tree.dart'; // Keep the Decision Tree for logic
import '../design/app_time_prompt_dialog.dart'; // Import the dialog for app time scheduling
import '../design/dialog_prompt.dart'; // Import DialogPrompt to show the info to parents

class AppManagement extends StatefulWidget {
  final String childId;
  final String parentId;

  const AppManagement({super.key, required this.childId, required this.parentId});

  @override
  AppManagementState createState() => AppManagementState();
}

class AppManagementState extends State<AppManagement> {
  List<Map<String, dynamic>> apps = [];
  bool isLoading = true;
  final Logger _logger = Logger('AppManagement');
  final AppService appService = AppService();
  final AppToggleService appToggleService = AppToggleService();

  @override
  void initState() {
    super.initState();
    fetchApps(); // Fetch the apps when the widget is initialized
    showLoadingDialog(); // Show the loading info dialog
  }

  @override
  void didUpdateWidget(covariant AppManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fetch new apps if the childId changes
    if (oldWidget.childId != widget.childId) {
      fetchApps();
      showLoadingDialog(); // Show the loading info dialog when childId changes
    }
  }

  // Show the loading dialog
  void showLoadingDialog() {
    DialogPrompt.showLoading(context); // Show the loading dialog to the parent
  }

  // Fetch apps using the AppService (from app_management collection)
  void fetchApps() async {
    try {
      _logger.info("Fetching apps for childId: ${widget.childId} and parentId: ${widget.parentId}");

      // Sync app_management with app_list and then fetch apps from app_management
      await appService.syncAppManagement(widget.childId, widget.parentId); // Sync first
      List<Map<String, dynamic>> fetchedApps = await appService.fetchAppManagement(widget.childId); // Then fetch

      setState(() {
        apps = fetchedApps;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _logger.severe("Error fetching apps from app_management", e);
    }
  }

  // Toggle the allowed status and integrate decision tree logic
  void toggleAllowedStatus(int index) async {
    bool isAllowed = apps[index]['is_allowed'] == true;
    bool newStatus = !isAllowed; // Toggle the current status

    // Decision tree logic
    AppDecision decision = AppDecision(
      isAllowed: newStatus,  // Pass the new status to the decision tree
      setTimeSchedule: newStatus == true,  // Show time schedule only if new status is ON
    );

    String decisionResult = decision.makeDecision();
    _logger.info('Decision result: $decisionResult');

    if (decisionResult == 'Block App (Toggle OFF)') {
      // Toggle OFF: Set is_allowed to false and update in app_management
      setState(() {
        apps[index]['is_allowed'] = false; // Update UI
      });

      // Update the backend with the new status (is_allowed: false)
      await appToggleService.updateAppToggleStatus(
        apps[index]['package_name'],
        false, // Pass the new status (false) to the backend
        widget.childId,
        widget.parentId,
      );
      _logger.info("App ${apps[index]['app_name']} blocked (is_allowed: false)");

    } else if (decisionResult == 'Allow App (No Time Schedule, Toggle ON)') {
      // Toggle ON: Set is_allowed to true and update in app_management
      setState(() {
        apps[index]['is_allowed'] = true; // Update UI
      });

      // Update the backend with the new status (is_allowed: true)
      await appToggleService.updateAppToggleStatus(
        apps[index]['package_name'],
        true, // Pass the new status (true) to the backend
        widget.childId,
        widget.parentId,
      );
      _logger.info("App ${apps[index]['app_name']} allowed (is_allowed: true)");

    } else if (decisionResult == 'Set App Time Schedule Prompt') {
      // Toggle ON with time schedule prompt
      setState(() {
        apps[index]['is_allowed'] = true; // Update UI
      });

      // Update the backend with the new status (is_allowed: true)
      await appToggleService.updateAppToggleStatus(
        apps[index]['package_name'],
        true, // Pass the new status (true) to the backend
        widget.childId,
        widget.parentId,
      );
      _logger.info("App ${apps[index]['app_name']} allowed (is_allowed: true) with time schedule prompt");

      // Show the time scheduling prompt after updating the backend
      openToggleDialog(apps[index]['_id'], apps[index]['app_name']);
    } else {
      _logger.warning('Unexpected decision result');
    }
  }

  // Open the AppTogglePrompt dialog for toggling
  void openToggleDialog(String appId, String appName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),  // Add opacity to the background
      builder: (context) => AppTogglePrompt(
        appId: appId,
        childId: widget.childId,
        appName: appName,
      ),
    );
  }

// Function to display the schedule prompt
void openScheduleDialog(String appId, String appName) {
  showDialog(
    context: context,
    builder: (context) => AppTogglePrompt(
      appId: appId,
      childId: widget.childId,
      appName: appName,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle fontStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18, // Set font size to 18, same as time management schedule
        );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: appBarColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Center(
              child: Text(
                'Manage Child’s Apps',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : apps.isEmpty
                  ? const Center(child: Text("No apps found."))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: apps.length,
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    app['app_name'],
                                    style: fontStyle, // Apply theme style with larger font size
                                  ),
                                ),
                                Switch(
                                  value: app['is_allowed'] == true, // Ensure toggle reflects correct is_allowed state
                                  activeColor: Colors.white, // Thumb color when active
                                  activeTrackColor: Colors.green, // Track color when active
                                  inactiveThumbColor: Colors.white, // Thumb color when inactive
                                  inactiveTrackColor: Colors.grey[400], // Track color when inactive (with grey shade)
                                  onChanged: (value) => toggleAllowedStatus(index), // Handle toggle with decision tree
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.access_time, // Clock icon
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    // Open schedule dialog when clock icon is clicked
                                    openScheduleDialog(app['_id'], app['app_name']);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}*/

/*
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../design/app_toggle_prompt.dart'; // This import is now used
import '../services/app_toggle_service.dart';
import '../services/app_service.dart';
import '../algorithm/decision_tree.dart';

class AppManagement extends StatefulWidget {
  final String childId;
  final String parentId;

  const AppManagement({super.key, required this.childId, required this.parentId});

  @override
  AppManagementState createState() => AppManagementState();
}

class AppManagementState extends State<AppManagement> {
  List<Map<String, dynamic>> apps = [];
  bool isLoading = true;
  final Logger _logger = Logger('AppManagement');
  final AppService appService = AppService();
  final AppToggleService appToggleService = AppToggleService();

  @override
  void initState() {
    super.initState();
    fetchApps();
  }

  @override
  void didUpdateWidget(covariant AppManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      fetchApps();
    }
  }

  // Fetch apps using the AppService
  void fetchApps() async {
    try {
      _logger.info("Fetching apps for childId: ${widget.childId} and parentId: ${widget.parentId}");

      List<Map<String, dynamic>> fetchedApps = await appService.fetchAppManagement(widget.childId);

      setState(() {
        apps = fetchedApps;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _logger.severe("Error fetching apps from app_management", e);
    }
  }

  // Toggle the allowed status and integrate decision tree logic
  void toggleAllowedStatus(int index) async {
  bool currentStatus = apps[index]['is_allowed'] == true; // Get current status
  bool newStatus = !currentStatus; // Toggle the current status

  // Decision tree logic
  AppDecision decision = AppDecision(
    isAllowed: newStatus,  // Pass the new status to the decision tree
    setTimeSchedule: false,  // Initially set to false
  );

  String decisionResult = decision.makeDecision();
  _logger.info('Decision result: $decisionResult');

  if (decisionResult == 'Block App (Toggle OFF)') {
    // Toggle OFF: Set is_allowed to false and update in app_management
    setState(() {
      apps[index]['is_allowed'] = false; // Update UI
    });

    // Update the backend with the new status (is_allowed: false)
    await appToggleService.updateAppToggleStatus(
      apps[index]['package_name'],
      false, // Pass the new status (false) to the backend
      widget.childId,
      widget.parentId,
    );
    _logger.info("App ${apps[index]['app_name']} blocked (is_allowed: false)");
  } else if (decisionResult == 'Allow App (No Time Schedule, Toggle ON)') {
    // Toggle ON: Set is_allowed to true and update in app_management
    setState(() {
      apps[index]['is_allowed'] = true; // Update UI
    });

    // Update the backend with the new status (is_allowed: true)
    await appToggleService.updateAppToggleStatus(
      apps[index]['package_name'],
      true, // Pass the new status (true) to the backend
      widget.childId,
      widget.parentId,
    );
    _logger.info("App ${apps[index]['app_name']} allowed (is_allowed: true)");
  } else if (decisionResult == 'Set App Time Schedule Prompt') {
    // Toggle ON with time schedule prompt
    setState(() {
      apps[index]['is_allowed'] = true; // Update UI
    });

    // Update the backend with the new status (is_allowed: true)
    await appToggleService.updateAppToggleStatus(
      apps[index]['package_name'],
      true, // Pass the new status (true) to the backend
      widget.childId,
      widget.parentId,
    );
    _logger.info("App ${apps[index]['app_name']} allowed (is_allowed: true) with time schedule prompt");

    // Show the time scheduling prompt after updating the backend
    openScheduleDialog(apps[index]['_id'], apps[index]['app_name']);
  } else {
    _logger.warning('Unexpected decision result');
  }
}
// Function to display the schedule prompt
void openScheduleDialog(String appId, String appName) {
  showDialog(
    context: context,
    builder: (context) => AppTogglePrompt(
      appId: appId,
      childId: widget.childId,
      appName: appName,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle fontStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: appBarColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Center(
              child: Text(
                'Manage Child’s Apps',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : apps.isEmpty
                  ? const Center(child: Text("No apps found."))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: apps.length,
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    app['app_name'],
                                    style: fontStyle,
                                  ),
                                ),
                                Switch(
                                  value: app['is_allowed'] == true,
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.green,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey[400],
                                  onChanged: (value) => toggleAllowedStatus(index),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.access_time,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    openScheduleDialog(app['_id'], app['app_name']);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
*/