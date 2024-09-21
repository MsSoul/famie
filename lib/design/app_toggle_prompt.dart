import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_time_management_service.dart'; // Create this service to save time slots

class AppTogglePrompt extends StatefulWidget {
  final String appId;
  final String childId;
  final String appName;

  const AppTogglePrompt({
    super.key,
    required this.appId,
    required this.childId,
    required this.appName,
  });

  @override
  AppTogglePromptState createState() => AppTogglePromptState();
}

class AppTogglePromptState extends State<AppTogglePrompt> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Time Schedule for ${widget.appName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Start Time Picker
          ListTile(
            title: const Text('Start Time'),
            trailing: Text(startTime != null ? startTime!.format(context) : 'Not set'),
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  startTime = pickedTime;
                });
              }
            },
          ),
          // End Time Picker
          ListTile(
            title: const Text('End Time'),
            trailing: Text(endTime != null ? endTime!.format(context) : 'Not set'),
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  endTime = pickedTime;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (startTime != null && endTime != null) {
              saveTimeSchedule(); // Save the time schedule
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select both start and end times')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void saveTimeSchedule() {
    // Convert TimeOfDay to String
    String startTimeString = DateFormat.Hm().format(
      DateTime(0, 0, 0, startTime!.hour, startTime!.minute),
    );
    String endTimeString = DateFormat.Hm().format(
      DateTime(0, 0, 0, endTime!.hour, endTime!.minute),
    );

    // Use a service to save the schedule
    AppTimeManagementService().saveTimeSchedule(
      appId: widget.appId,
      childId: widget.childId,
      startTime: startTimeString,
      endTime: endTimeString,
    );
  }
}
