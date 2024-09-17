// filename:home.dart
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
