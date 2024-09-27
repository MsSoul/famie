// filename: settings_widget.dart
import 'package:flutter/material.dart';
import 'time_management.dart'; // Adjust this import to your file structure
import 'app_management.dart'; // Adjust this import to your file structure


class SettingsWidget extends StatefulWidget {
  final String childId;
  final String parentId; // Add parentId as a required field

  const SettingsWidget({super.key, required this.childId, required this.parentId});

  @override
  SettingsWidgetState createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
  String selectedSetting = 'Time Management';

  @override
  Widget build(BuildContext context) {
    // Get app bar color from the theme, or use green as a default if it's not available
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle headerTextStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: appBarColor, // Ensure the text color matches the app bar color from the theme
        ) ??
        const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green); // Fallback style

    return Column(
      children: [
        // Removed the top margin for "SETTINGS" text
        Text('SETTINGS', style: headerTextStyle),
        const SizedBox(height: 0), // Adjusted spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margin on the left and right
                child: SettingsCard(
                  icon: Icons.access_time,
                  title: 'Time Management',
                  selected: selectedSetting == 'Time Management',
                  onTap: () {
                    setState(() {
                      selectedSetting = 'Time Management';
                    });
                  },
                  backgroundColor: selectedSetting == 'Time Management' ? appBarColor : Colors.grey[300],
                  iconColor: selectedSetting == 'Time Management' ? Colors.white : Colors.green[800],
                  textColor: selectedSetting == 'Time Management' ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margin on the left and right
                child: SettingsCard(
                  icon: Icons.app_settings_alt,
                  title: 'App Management',
                  selected: selectedSetting == 'App Management',
                  onTap: () {
                    setState(() {
                      selectedSetting = 'App Management';
                    });
                  },
                  backgroundColor: selectedSetting == 'App Management' ? appBarColor : Colors.grey[300],
                  iconColor: selectedSetting == 'App Management' ? Colors.white : Colors.green[800],
                  textColor: selectedSetting == 'App Management' ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.green, height: 2),
        Expanded(
          child: selectedSetting == 'Time Management'
              ? TimeManagement(childId: widget.childId) // Ensure TimeManagement class exists
              : AppManagement(childId: widget.childId, parentId: widget.parentId),  // Pass both childId and parentId
        ),
      ],
    );
  }
}

// Define the SettingsCard widget below
class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color? backgroundColor; // Add background color property
  final Color? iconColor; // Add icon color property
  final Color? textColor; // Add text color property

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.backgroundColor, // Add background color
    this.iconColor, // Add icon color
    this.textColor, // Add text color
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor, // Use background color for the card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Icon(icon, size: 40, color: iconColor ?? Colors.black), // Use icon color
                  const SizedBox(height: 8),
                  // Use FittedBox to ensure the text size adjusts based on the screen size and avoid overflow
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Georgia', // Use Georgia font style
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: textColor ?? Colors.black, // Use text color
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/*working ni, ge comment lang nimo ni kay mag butang ka anang prompt
import 'package:flutter/material.dart';
import 'time_management.dart'; // Adjust this import to your file structure
import 'app_management.dart'; // Adjust this import to your file structure

class SettingsWidget extends StatefulWidget {
  final String childId;
  final String parentId; // Add parentId as a required field

  const SettingsWidget({super.key, required this.childId, required this.parentId});

  @override
  SettingsWidgetState createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
  String selectedSetting = 'Time Management';

  @override
  Widget build(BuildContext context) {
    // Get app bar color from the theme, or use green as a default if it's not available
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle headerTextStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: appBarColor, // Ensure the text color matches the app bar color from the theme
        ) ??
        const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green); // Fallback style

    return Column(
      children: [
        // Removed the top margin for "SETTINGS" text
        Text('SETTINGS', style: headerTextStyle),
        const SizedBox(height: 3), // Adjusted spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margin on the left and right
                child: SettingsCard(
                  icon: Icons.access_time,
                  title: 'Time Management',
                  selected: selectedSetting == 'Time Management',
                  onTap: () {
                    setState(() {
                      selectedSetting = 'Time Management';
                    });
                  },
                  backgroundColor: selectedSetting == 'Time Management' ? appBarColor : Colors.grey[300],
                  iconColor: selectedSetting == 'Time Management' ? Colors.white : Colors.green[800],
                  textColor: selectedSetting == 'Time Management' ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margin on the left and right
                child: SettingsCard(
                  icon: Icons.app_settings_alt,
                  title: 'App Management',
                  selected: selectedSetting == 'App Management',
                  onTap: () {
                    setState(() {
                      selectedSetting = 'App Management';
                    });
                  },
                  backgroundColor: selectedSetting == 'App Management' ? appBarColor : Colors.grey[300],
                  iconColor: selectedSetting == 'App Management' ? Colors.white : Colors.green[800],
                  textColor: selectedSetting == 'App Management' ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.green, height: 2),
        Expanded(
          child: selectedSetting == 'Time Management'
              ? TimeManagement(childId: widget.childId) // Ensure TimeManagement class exists
              : AppManagement(childId: widget.childId, parentId: widget.parentId),  // Pass both childId and parentId
        ),
      ],
    );
  }
}

// Define the SettingsCard widget below
class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color? backgroundColor; // Add background color property
  final Color? iconColor; // Add icon color property
  final Color? textColor; // Add text color property

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.backgroundColor, // Add background color
    this.iconColor, // Add icon color
    this.textColor, // Add text color
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor, // Use background color for the card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Icon(icon, size: 40, color: iconColor ?? Colors.black), // Use icon color
                  const SizedBox(height: 8),
                  // Use FittedBox to ensure the text size adjusts based on the screen size and avoid overflow
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Georgia', // Use Georgia font style
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: textColor ?? Colors.black, // Use text color
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

*/
/*
// filename: settings_widget.dart
import 'package:flutter/material.dart';
// import '../design/theme.dart'; // Ensure this points to your theme.dart
import 'time_management.dart'; // Adjust this import to your file structure
import 'app_management.dart'; // Adjust this import to your file structure

class SettingsWidget extends StatefulWidget {
  final String childId;

  const SettingsWidget({super.key, required this.childId});

  @override
  SettingsWidgetState createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
  String selectedSetting = 'Time Management';

  @override
  Widget build(BuildContext context) {
    // Get app bar color from the theme, or use green as a default if it's not available
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle headerTextStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: appBarColor, // Ensure the text color matches the app bar color from the theme
        ) ??
        const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green); // Fallback style

    return Column(
      children: [
        // Removed the top margin for "SETTINGS" text
        Text('SETTINGS', style: headerTextStyle),
        const SizedBox(height: 3), // Adjusted spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margin on the left and right
                child: SettingsCard(
                  icon: Icons.access_time,
                  title: 'Time Management',
                  selected: selectedSetting == 'Time Management',
                  onTap: () {
                    setState(() {
                      selectedSetting = 'Time Management';
                    });
                  },
                  backgroundColor: selectedSetting == 'Time Management' ? appBarColor : Colors.grey[300],
                  iconColor: selectedSetting == 'Time Management' ? Colors.white : Colors.green[800],
                  textColor: selectedSetting == 'Time Management' ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margin on the left and right
                child: SettingsCard(
                  icon: Icons.app_settings_alt,
                  title: 'App Management',
                  selected: selectedSetting == 'App Management',
                  onTap: () {
                    setState(() {
                      selectedSetting = 'App Management';
                    });
                  },
                  backgroundColor: selectedSetting == 'App Management' ? appBarColor : Colors.grey[300],
                  iconColor: selectedSetting == 'App Management' ? Colors.white : Colors.green[800],
                  textColor: selectedSetting == 'App Management' ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.green, height: 2),
        Expanded(
          child: selectedSetting == 'Time Management'
              ? TimeManagement(childId: widget.childId) // Ensure TimeManagement class exists
              : AppManagement(childId: widget.childId),  // Ensure AppManagement class exists with childId
        ),
      ],
    );
  }
}

// Define the SettingsCard widget below
class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color? backgroundColor; // Add background color property
  final Color? iconColor; // Add icon color property
  final Color? textColor; // Add text color property

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.backgroundColor, // Add background color
    this.iconColor, // Add icon color
    this.textColor, // Add text color
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor, // Use background color for the card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Icon(icon, size: 40, color: iconColor ?? Colors.black), // Use icon color
                  const SizedBox(height: 8),
                  // Use FittedBox to ensure the text size adjusts based on the screen size and avoid overflow
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Georgia', // Use Georgia font style
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: textColor ?? Colors.black, // Use text color
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
*/