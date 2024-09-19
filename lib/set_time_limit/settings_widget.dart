// filename: settings_widget.dart
import 'package:flutter/material.dart';
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
              ? TimeManagement(childId: widget.childId) // TimeManagement needs childId
              : const AppManagement(),  // AppManagement does not need childId
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


/*
import 'package:flutter/material.dart';

class SettingsWidget extends StatefulWidget {
  final String parentId;
  final String childId;  // Add childId to focus on selected child

  const SettingsWidget({super.key, required this.parentId, required this.childId});

  @override
  SettingsWidgetState createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
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
          // Pass the selected childId to the relevant widget
          child: selectedSetting == 'Time Management'
              ? TimeManagement(childId: widget.childId)  // Pass the childId here
              : AppManagement(parentId: widget.parentId, childId: widget.childId),  // Pass the childId here
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