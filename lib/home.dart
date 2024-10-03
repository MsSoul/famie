// filename:home.dart
// filename: home.dart
import 'package:flutter/material.dart';
import 'design/theme.dart'; // Ensure you import the theme.dart file for customAppBar
import 'child_profile/scan_child.dart';
import 'dashboard/dashboard_screen.dart';
import 'set_time_limit/screentimelimit.dart';

class HomeScreen extends StatelessWidget {
  final String parentId;

  const HomeScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    // Retrieve the AppBar color from the theme
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: customAppBar(
        context, 
        'Home Screen', 
        isLoggedIn: true, 
        parentId: parentId // Pass the parentId here
      ), // Using the customAppBar from theme.dart
      body: Padding(
        padding: appMargin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
       Text(
  'Hi Parent!',
  textAlign: TextAlign.center,
  style: textTheme.titleLarge?.copyWith(
    fontSize: 24.0, // Override font size
    fontWeight: FontWeight.bold, // Override font weight
    color: appBarColor, // Use the AppBar color for the text
  ),
),
            const SizedBox(height: 15),
            // Register Child Menu Item
            MenuItem(
              iconData: Icons.person_add,
              title: 'Register Child',
              iconColor: appBarColor, // Apply AppBar color to the icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildRegistrationScreen(
                      parentId: parentId, // Ensure parentId is passed correctly
                      onChildRegistered: (String childName, String childAvatar) {
                        // Handle the callback if needed
                      },
                    ),
                  ),
                );
              },
            ),
            // Dashboard Menu Item
            MenuItem(
              iconData: Icons.dashboard,
              title: 'Dashboard',
              iconColor: appBarColor, // Apply AppBar color to the icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                      parentId: parentId, // Ensure parentId is passed correctly
                    ),
                  ),
                );
              },
            ),
            // Set Screen Time Menu Item
            MenuItem(
              iconData: Icons.timer,
              title: 'Set Screen Time Schedule',
              iconColor: appBarColor, // Apply AppBar color to the icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScreenTimeLimitScreen(
                      parentId: parentId, // Ensure parentId is passed correctly
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor; // Add an iconColor parameter

  const MenuItem({
    super.key,
    required this.iconData,
    required this.title,
    required this.onTap,
    this.iconColor, // Initialize iconColor
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        leading: Icon(iconData, color: iconColor ?? Colors.green), // Use iconColor from the parameter, fallback to green
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 8, 8, 8), // You can customize this as needed
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/*e modify cay mag change ug theme design
import 'package:flutter/material.dart';
import 'design/theme.dart'; // Ensure you import the theme.dart file for customAppBar
import 'child_profile/scan_child.dart';
import 'dashboard/dashboard_screen.dart';
import 'set_time_limit/screentimelimit.dart';

class HomeScreen extends StatelessWidget {
  final String parentId;

  const HomeScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context, 
        'Home Screen', 
        isLoggedIn: true, 
        parentId: parentId // Pass the parentId here
      ), // Using the customAppBar from theme.dart
      body: Padding(
        padding: appMargin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hi Parent!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 15),
            // Register Child Menu Item
            MenuItem(
              iconData: Icons.person_add,
              title: 'Register Child',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildRegistrationScreen(
                      parentId: parentId, // Ensure parentId is passed correctly
                      onChildRegistered: (String childName, String childAvatar) {
                        // Handle the callback if needed
                      },
                    ),
                  ),
                );
              },
            ),
            // Dashboard Menu Item
            MenuItem(
              iconData: Icons.dashboard,
              title: 'Dashboard',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                      parentId: parentId, // Ensure parentId is passed correctly
                    ),
                  ),
                );
              },
            ),
            // Set Screen Time Menu Item
            MenuItem(
              iconData: Icons.timer,
              title: 'Set Screen Time Schedule',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScreenTimeLimitScreen(
                      parentId: parentId, // Ensure parentId is passed correctly
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.iconData,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(iconData, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 8, 8, 8),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'design/theme.dart';
import 'child_profile/scan_child.dart'; 
import 'dashboard/dashboard_screen.dart'; 
import 'set_time_limit/screentimelimit.dart'; 

class HomeScreen extends StatelessWidget {
  final String parentId;

  const HomeScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Home Screen', isLoggedIn: true),
      body: Padding(
        padding: appMargin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hi Parent!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 15),
            MenuItem(
              iconData: Icons.person_add,
              title: 'Register Child',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildRegistrationScreen(
                      parentId: parentId,
                      onChildRegistered: (String childName, String childAvatar) {
                        // Handle the callback here if needed
                      },
                    ),
                  ),
                );
              },
            ),
            MenuItem(
              iconData: Icons.dashboard,
              title: 'Dashboard',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(parentId: parentId),
                  ),
                );
              },
            ),
           /* MenuItem(
              iconData: Icons.timer,
              title: 'Set Screen Time Schedule',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScreenTimeLimitScreen(parentId: parentId),
                  ),
                );
              },
            ),*/
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.iconData,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(iconData, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 8, 8, 8),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
*/