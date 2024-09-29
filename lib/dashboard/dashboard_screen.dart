// filename: dashboard/dashboard_screen.dart
// filename: dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../child_profile/child_profile_provider.dart';
import '../child_profile/child_profile_widget.dart';
import '../design/theme.dart'; // Import the custom theme for app bar
import 'dashboard_screen_time.dart';
import 'dashboard_app_time.dart';

class DashboardScreen extends StatelessWidget {
  final String parentId; // Still needed here for API calls

  const DashboardScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    final childProfileProvider = Provider.of<ChildProfileProvider>(context);
    final Logger logger = Logger(); // Initialize logger

    void onChildSelected(String childId) {
      logger.i('Selected childId: $childId'); // Log child selection
      childProfileProvider.setSelectedChildId(childId);
    }

    // Load children profiles if they haven't been loaded yet
    if (!childProfileProvider.isLoading && childProfileProvider.children.isEmpty) {
      childProfileProvider.loadChildren(parentId);
    }

    return Scaffold(
      appBar: customAppBar(context, 'Dashboard', isLoggedIn: true, parentId: parentId), // Pass parentId here
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
        children: [
          // Child Profile Widget without any margin or padding
          ChildProfileWidget(
            parentId: parentId,
            onChildSelected: onChildSelected, // Callback for child selection
          ),

          // Centered Dashboard Text with app bar color, no padding or margin
          Center(
            child: Column(
              children: [
                // 'Dashboard' Text
                Text(
                  'Dashboard',  // Display 'Dashboard' text
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).appBarTheme.backgroundColor, // Same color as app bar
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                
                // Add margin below the 'Dashboard' text
                const SizedBox(height: 10),  // Adjust height to control the margin
              ],
            ),
          ),

          // Dashboard content based on child selection
          Expanded(
            child: childProfileProvider.selectedChildId == null
                ? const Center(child: Text('Please select a child to view the dashboard'))
                : Column(
                    children: [
                      Expanded(
                        child: DashboardScreenTime(childId: childProfileProvider.selectedChildId!), // Display Screen Time for selected child
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: DashboardAppTime(childId: childProfileProvider.selectedChildId!), // Display App Time for selected child
                      ),
                    ],
                  ),
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
import '../design/theme.dart'; // Import the custom theme for app bar
import 'dashboard_screen_time.dart';
import 'dashboard_app_time.dart';

class DashboardScreen extends StatelessWidget {
  final String parentId; // Still needed here for API calls

  const DashboardScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    final childProfileProvider = Provider.of<ChildProfileProvider>(context);
    final Logger logger = Logger(); // Initialize logger

    void onChildSelected(String childId) {
      logger.i('Selected childId: $childId'); // Log child selection
      childProfileProvider.setSelectedChildId(childId);
    }

    // Load children profiles if they haven't been loaded yet
    if (!childProfileProvider.isLoading && childProfileProvider.children.isEmpty) {
      childProfileProvider.loadChildren(parentId);
    }

    return Scaffold(
      appBar: customAppBar(context, 'Dashboard', isLoggedIn: true, parentId: parentId), // Pass parentId here
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
        children: [
          // Child Profile Widget without any margin or padding
          ChildProfileWidget(
            parentId: parentId,
            onChildSelected: onChildSelected, // Callback for child selection
          ),

          // Centered Dashboard Text with app bar color, no padding or margin
          Center(
            child: Text(
              'Dashboard',  // Display 'Dashboard' text
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).appBarTheme.backgroundColor, // Same color as app bar
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),

          // Dashboard content based on child selection
          Expanded(
            child: childProfileProvider.selectedChildId == null
                ? const Center(child: Text('Please select a child to view the dashboard'))
                : Column(
                    children: [
                      Expanded(
                        child: DashboardScreenTime(childId: childProfileProvider.selectedChildId!), // Display Screen Time for selected child
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: DashboardAppTime(childId: childProfileProvider.selectedChildId!), // Display App Time for selected child
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
*/