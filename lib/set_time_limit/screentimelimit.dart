//filename:set_time_limit/screentimelimit.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../child_profile/child_profile_provider.dart';
import '../child_profile/child_profile_widget.dart';
import '../design/theme.dart'; 
import 'settings_widget.dart'; 

class ScreenTimeLimitScreen extends StatefulWidget {
  final String parentId; 

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
                      ? SettingsWidget(childId: selectedChildId!, parentId: widget.parentId)  // Pass both childId and parentId
                      : const Center(child: Text('No Child Added Yet.')),
                ),
              ],
            ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../child_profile/child_profile_provider.dart';
import '../child_profile/child_profile_widget.dart';
import '../design/theme.dart'; 
import 'settings_widget.dart'; 

class ScreenTimeLimitScreen extends StatefulWidget {
  final String parentId; 

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
                      ? SettingsWidget(childId: selectedChildId!, parentId: widget.parentId)  // Pass both childId and parentId
                      : const Center(child: Text('No Child Added Yet.')),
                ),
              ],
            ),
    );
  }
}
*/
/*
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
*/