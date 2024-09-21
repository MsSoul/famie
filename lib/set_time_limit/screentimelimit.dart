//filename:set_time_limit/screentimelimit.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../child_profile/child_profile_provider.dart';
import '../child_profile/child_profile_widget.dart';
import '../design/theme.dart';  // Import the custom theme for app bar
import 'settings_widget.dart';  // Import the new settings widget

class ScreenTimeLimitScreen extends StatefulWidget {
  final String parentId;  // Still needed here for API calls

  const ScreenTimeLimitScreen({super.key, required this.parentId});

  @override
  ScreenTimeLimitScreenState createState() => ScreenTimeLimitScreenState();
}

class ScreenTimeLimitScreenState extends State<ScreenTimeLimitScreen> {
  String? selectedChildId;  // This will hold the selected child's ID
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    final childProfileProvider = Provider.of<ChildProfileProvider>(context);

    // Function to handle when a child is selected
    void onChildSelected(String childId) {
      setState(() {
        selectedChildId = childId;  // Update the selectedChildId
      });
      logger.i('Selected childId: $childId');
    }

    // Load children profiles if they haven't been loaded yet
    if (!childProfileProvider.isLoading && childProfileProvider.children.isEmpty) {
      childProfileProvider.loadChildren(widget.parentId);
    }

    return Scaffold(
      appBar: customAppBar(context, 'Set Screen Time', isLoggedIn: true, parentId: widget.parentId),
      body: childProfileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())  // Show loader while loading
          : Column(
              children: [
                ChildProfileWidget(
                  parentId: widget.parentId,  // Passing the parentId here for fetching data
                  onChildSelected: onChildSelected,
                ),
                const SizedBox(height: 20),
                Expanded(
                  // Show the SettingsWidget only if a child is selected
                  child: selectedChildId != null
                      ? SettingsWidget(childId: selectedChildId!)
                      : const Center(child: Text('Please select a child')),
                ),
              ],
            ),
    );
  }
}

/*

import 'package:flutter/material.dart';
import '../main.dart';
import '../child_profile/scan_child.dart';
import 'time_management.dart';
import 'app_management.dart';
import '../home.dart';
import '../child_profile/child_profiling.dart';
import '../child_profile/child_profile_manager.dart';
import '../design/theme.dart'; // Import your custom theme file for the AppBar

class ScreenTimeLimitScreen extends StatefulWidget {
  final String parentId; // Changed to String

  const ScreenTimeLimitScreen({super.key, required this.parentId});

  @override
  ScreenTimeLimitScreenState createState() => ScreenTimeLimitScreenState();
}

class ScreenTimeLimitScreenState extends State<ScreenTimeLimitScreen> {
  final ChildProfileManager _childProfileManager = ChildProfileManager();
  Map<String, String>? selectedChild;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    await _childProfileManager.loadChildren(widget.parentId);
    setState(() {
      final children = _childProfileManager.getChildren();
      if (children.isNotEmpty) {
        selectedChild = children[0]; // Select the first child by default
      }
      _isLoading = false;
    });
  }

  Future<void> _addChild(String name, String avatar, String childRegistrationId) async {
    const String deviceId = 'ScannedDeviceName'; // Replace with actual device name
    const String macAddress = '00:00:00:00:00:00'; // Replace with actual MAC address
    await _childProfileManager.addChild(widget.parentId, childRegistrationId, name, avatar, deviceId, macAddress); // Added childRegistrationId
    await _loadChildren();
  }

  void _selectChild(Map<String, String> child) {
    setState(() {
      selectedChild = child;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Set Screen Time Schedule', isLoggedIn: true), // Use custom app bar from theme.dart
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator while fetching
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedChild != null)
                    _buildSelectedChildProfile(selectedChild!), // Display the selected child's profile
                  const SizedBox(height: 20),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const Divider(thickness: 2.0),
                  Expanded(
                    child: SettingsTab(parentId: widget.parentId),
                  ),
                ],
              ),
            ),
    );
  }

  // Build the profile view with only the selected child's avatar and name
  Widget _buildSelectedChildProfile(Map<String, String> child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(child['avatar'] ?? 'assets/avatar/default_avatar.png'),
          radius: 50, // Adjust the size of the avatar
          backgroundColor: Colors.transparent,
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback to default image if there's an error loading the avatar
            print('Error loading selected avatar: ${child['avatar']}, using default avatar.');
          },
        ),
        const SizedBox(height: 10), // Space between avatar and name
        Text(
          child['name'] ?? 'Unknown Name', // Show child's name
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20), // Space between profile and settings section
      ],
    );
  }
}

class SettingsTab extends StatefulWidget {
  final String parentId; // Changed to String

  const SettingsTab({super.key, required this.parentId});

  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab> {
  String selectedSetting = 'Time Management';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SettingsCard(
                icon: Icons.access_time,
                title: 'Time Management',
                selected: selectedSetting == 'Time Management',
                onTap: () {
                  setState(() {
                    selectedSetting = 'Time Management';
                  });
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SettingsCard(
                icon: Icons.app_settings_alt,
                title: 'App Management',
                selected: selectedSetting == 'App Management',
                onTap: () {
                  setState(() {
                    selectedSetting = 'App Management';
                  });
                },
              ),
            ),
          ],
        ),
        const Divider(thickness: 2.0),
        Expanded(
          child: selectedSetting == 'Time Management'
              ? const TimeManagement()
              : AppManagement(parentId: widget.parentId),
        ),
      ],
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: selected ? Colors.green[100] : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import '../main.dart';
import '../child_profile/scan_child.dart';
import 'time_management.dart';
import 'app_management.dart';
import '../home.dart';
import '../child_profile/child_profiling.dart';
import '../child_profile/child_profile_manager.dart';

class ScreenTimeLimitScreen extends StatefulWidget {
  final String parentId; // Changed to String

  const ScreenTimeLimitScreen({super.key, required this.parentId});

  @override
  ScreenTimeLimitScreenState createState() => ScreenTimeLimitScreenState();
}

class ScreenTimeLimitScreenState extends State<ScreenTimeLimitScreen> {
  final ChildProfileManager _childProfileManager = ChildProfileManager();
  Map<String, String>? selectedChild;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    await _childProfileManager.loadChildren(widget.parentId);
    setState(() {
      final children = _childProfileManager.getChildren();
      if (children.isNotEmpty) {
        selectedChild = children[0];
      }
    });
  }

  Future<void> _addChild(String name, String avatar, String childRegistrationId) async {
    const String deviceId = 'ScannedDeviceName'; // Replace with actual device name
    const String macAddress = '00:00:00:00:00:00'; // Replace with actual MAC address
    await _childProfileManager.addChild(widget.parentId, childRegistrationId, name, avatar, deviceId, macAddress); // Added childRegistrationId
    await _loadChildren();
  }

  void _selectChild(Map<String, String> child) {
    setState(() {
      selectedChild = child;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Image.asset(
          'assets/image2.png',
          height: 40.0,
          fit: BoxFit.cover,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            color: Colors.black,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(parentId: widget.parentId)),
                (Route<dynamic> route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: Colors.black,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_childProfileManager.getChildren().isEmpty)
              const Text('No children available'),
            if (_childProfileManager.getChildren().isNotEmpty)
              ChildProfiles(
                selectedChild: selectedChild,
                onChildSelected: _selectChild,
                onAddChild: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChildRegistrationScreen(
                            parentId: widget.parentId,
                            onChildRegistered: (String childName, String childAvatar) {
                            Navigator.pop(context);
                         // Since `childRegistrationId` isn't passed, either remove it or generate it here.
                         const String childRegistrationId = 'some_generated_id'; // Or get the ID from somewhere
                        _addChild(childName, childAvatar, childRegistrationId); // Now it matches the three-parameter function
                         },
                       ),
                    ),
                  );
                },
                parentId: widget.parentId, // Pass parentId to ChildProfiles
              ),
            const SizedBox(height: 20),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontFamily: 'Georgia',
              ),
            ),
            const Divider(thickness: 2.0),
            Expanded(
              child: SettingsTab(parentId: widget.parentId),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  final String parentId; // Changed to String

  const SettingsTab({super.key, required this.parentId});

  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab> {
  String selectedSetting = 'Time Management';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SettingsCard(
                icon: Icons.access_time,
                title: 'Time Management',
                selected: selectedSetting == 'Time Management',
                onTap: () {
                  setState(() {
                    selectedSetting = 'Time Management';
                  });
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SettingsCard(
                icon: Icons.app_settings_alt,
                title: 'App Management',
                selected: selectedSetting == 'App Management',
                onTap: () {
                  setState(() {
                    selectedSetting = 'App Management';
                  });
                },
              ),
            ),
          ],
        ),
        const Divider(thickness: 2.0),
        Expanded(
          child: selectedSetting == 'Time Management'
              ? const TimeManagement()
              : AppManagement(parentId: widget.parentId),
        ),
      ],
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: selected ? Colors.green[100] : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/