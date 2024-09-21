// filename: app_management.dart
// filename: app_management.dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../design/app_toggle_prompt.dart';
import '../services/app_toggle_service.dart'; // Import AppToggleService for posting to app_management
import '../services/app_service.dart'; // Import AppService for fetching from app_list
import '../algorithm/decision_tree.dart'; // Import your Decision Tree

class AppManagement extends StatefulWidget {
  final String childId;

  const AppManagement({super.key, required this.childId});

  @override
  AppManagementState createState() => AppManagementState();
}

class AppManagementState extends State<AppManagement> {
  List<Map<String, dynamic>> apps = [];
  bool isLoading = true;
  final Logger _logger = Logger('AppManagement');
  final AppService appService = AppService(); // Use AppService to fetch app_list
  final AppToggleService appToggleService = AppToggleService(); // Use AppToggleService to post to app_management

  @override
  void initState() {
    super.initState();
    fetchApps(); // Fetch the apps when the widget is initialized
  }

  @override
  void didUpdateWidget(covariant AppManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fetch new apps if the childId changes
    if (oldWidget.childId != widget.childId) {
      fetchApps();
    }
  }

  // Fetch apps using the AppService (from app_list collection)
  void fetchApps() async {
    try {
      _logger.info("Fetching apps for childId: ${widget.childId}");

      List<Map<String, dynamic>> fetchedApps = await appService.fetchAppList(widget.childId);

      setState(() {
        apps = fetchedApps;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _logger.severe("Error fetching apps from app_list", e);
    }
  }

  // Toggle allowed status and integrate decision tree logic
  void toggleAllowedStatus(int index) async {
    bool isAllowed = apps[index]['is_allowed'] == true;
    bool setTimeSchedule = apps[index]['set_time_schedule'] == true;

    // Create a new instance of AppDecision based on the toggle states
    AppDecision decision = AppDecision(
      isAllowed: !isAllowed, // Toggling the current state
      setTimeSchedule: setTimeSchedule, // Keep time schedule as is
    );

    // Get the decision from the decision tree
    String decisionResult = decision.makeDecision();
    _logger.info(decisionResult); // Use logger instead of print

    // Handle what happens based on the decision
    switch (decisionResult) {
      case 'Block App':
        // Logic to block the app
        break;
      case 'Set App Time Schedule':
        // Open the scheduling dialog if the decision is to set a time schedule
        openScheduleDialog(apps[index]['_id'], apps[index]['app_name']);
        break;
      case 'Allow App (No Time Schedule)':
        // Logic to allow the app without a time schedule
        break;
    }

    // Update the UI and send toggle state to the backend (app_management)
    setState(() {
      apps[index]['is_allowed'] = !isAllowed;
    });

    // Call the service to save the toggle state (post to app_management)
    await appToggleService.updateAppToggleStatus(
      apps[index]['_id'], // appId from app_list
      apps[index]['is_allowed'], // Whether the app is allowed or not
      widget.childId, // Pass childId to save in app_management
    );
  }

  // Open the AppTogglePrompt for scheduling
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
                                  value: app['is_allowed'] == true,
                                  activeColor: Colors.white, // Thumb color when active
                                  activeTrackColor: Colors.green, // Track color when active
                                  inactiveThumbColor: Colors.white, // Thumb color when inactive
                                  inactiveTrackColor: Colors.grey[400], // Track color when inactive (with grey shade)
                                  onChanged: (value) => toggleAllowedStatus(index),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.access_time, // Clock icon
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    // Open schedule dialog
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

/*
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/app_service.dart'; // Import your AppService

class AppManagement extends StatefulWidget {
  final String childId;

  const AppManagement({super.key, required this.childId});

  @override
  AppManagementState createState() => AppManagementState();
}

class AppManagementState extends State<AppManagement> {
  List<Map<String, dynamic>> apps = [];
  bool isLoading = true;
  final Logger _logger = Logger('AppManagement');
  final AppService appService = AppService(); // Initialize AppService

  @override
  void initState() {
    super.initState();
    fetchApps(); // Fetch the apps when the widget is initialized
  }

  @override
  void didUpdateWidget(covariant AppManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fetch new apps if the childId changes
    if (oldWidget.childId != widget.childId) {
      fetchApps();
    }
  }

  // Fetch apps using the AppService
  void fetchApps() async {
    try {
      _logger.info("Fetching apps for childId: ${widget.childId}");

      List<Map<String, dynamic>> fetchedApps = await appService.fetchAppList(widget.childId);

      // Sort apps by toggle state and then alphabetically within each group
      fetchedApps.sort((a, b) {
        if (a['is_allowed'] != b['is_allowed']) {
          return a['is_allowed'] ? -1 : 1; // Group by is_allowed
        }
        return a['app_name'].compareTo(b['app_name']); // Alphabetical order within each group
      });

      setState(() {
        apps = fetchedApps;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _logger.severe("Error fetching apps", e);
    }
  }

  // Toggle allowed status
  void toggleAllowedStatus(int index) async {
    bool isAllowed = apps[index]['is_allowed'] == true;

    setState(() {
      apps[index]['is_allowed'] = !isAllowed;
      // Sort apps again after toggling
      apps.sort((a, b) {
        if (a['is_allowed'] != b['is_allowed']) {
          return a['is_allowed'] ? -1 : 1;
        }
        return a['app_name'].compareTo(b['app_name']);
      });
    });

    // You can send a request to the backend here to update the status if needed
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
                                    value: app['is_allowed'] == true,
                                    activeColor: Colors.white, // Thumb color when active
                                    activeTrackColor: Colors.green, // Track color when active
                                    inactiveThumbColor: Colors.white, // Thumb color when inactive
                                    inactiveTrackColor: Colors.grey[400], // Track color when inactive (with grey shade)
                                    onChanged: (value) => toggleAllowedStatus(index),
                                    // The thumb will be white in both states, but the track color changes between active (green) and inactive (white with grey)
                                  ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.access_time, // Clock icon
                                  size: 40,
                                  color: Colors.green,
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