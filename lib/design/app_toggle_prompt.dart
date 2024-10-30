// filename: design/app_toggle_prompt.dart (setting app time schedule)
// filename: design/app_toggle_prompt.dart (setting app time schedule)
import 'package:flutter/material.dart';
import '../services/app_toggle_service.dart'; // Import your service
import 'dialog_prompt.dart'; // Import the Dialog Prompt widget
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';


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
  final Logger logger = Logger();

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void saveTimeSchedule() async {
  if (startTime != null && endTime != null) {
    // Convert TimeOfDay to DateTime for today
    DateTime now = DateTime.now();
    DateTime startDateTime = DateTime(now.year, now.month, now.day, startTime!.hour, startTime!.minute);
    DateTime endDateTime = DateTime(now.year, now.month, now.day, endTime!.hour, endTime!.minute);

    List<Map<String, String>> timeSlots = [
      {
        // Format the times to 24-hour format
        'start_time': DateFormat.Hm().format(startDateTime), // e.g., "13:00"
        'end_time': DateFormat.Hm().format(endDateTime),     // e.g., "14:00"
      }
    ];

    logger.i('Preparing to validate time slots: $timeSlots');

    try {
      // Fetch allowed time slots from your backend
      List<Map<String, String>> allowedSlots = await AppToggleService().fetchAllowedTimeSlots(widget.childId);
      logger.i('Allowed slots fetched: $allowedSlots');

      // Validate the selected schedule against allowed slots
      bool isValid = AppToggleService().isScheduleValid(timeSlots, allowedSlots);
      logger.i('Schedule validity check: $isValid');

      if (!isValid) {
        DialogPrompt.showInvalidSchedule(context);
        logger.w('Schedule is invalid.');
        return;
      }

      logger.i('Attempting to send save request for time schedule...');

      // Save the schedule
      await AppToggleService().saveTimeSchedule(widget.appName, widget.childId, timeSlots);
      logger.i('Time schedule save request completed successfully.');

      Navigator.of(context).pop(); // Close dialog
      DialogPrompt.showSuccess(context);

    } catch (error) {
      // Handle specific error types if needed, or just log and show a generic error
      logger.e('Failed to save schedule: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving schedule: $error')));
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both start and end times')));
    logger.w('No start or end time selected.');
  }
}


  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor, width: 2),
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            padding: const EdgeInsets.all(0),
            iconSize: 32,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Flexible(
            child: Text(
              'Set Time Schedule for ${widget.appName}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Georgia',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.check, color: appBarColor),
            padding: const EdgeInsets.all(0),
            iconSize: 32,
            onPressed: saveTimeSchedule,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Start Time',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectTime(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: appBarColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  startTime != null ? startTime!.format(context) : 'Set Time',
                  style: TextStyle(
                    color: appBarColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'End Time',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectTime(context, false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: appBarColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  endTime != null ? endTime!.format(context) : 'Set Time',
                  style: TextStyle(
                    color: appBarColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              DialogPrompt.show(context); // Show the dialog with information
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appBarColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'App Time Schedule Info',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}



/*e modify kay mag buttang ug dialog prompt 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_toggle_service.dart'; // Import your service
import 'dialog_prompt.dart'; // Import the Dialog Prompt widget

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

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green, // Use app bar color
              onPrimary: Colors.white, // Text color on selected items
              onSurface: Colors.black, // Default text color on surface
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void saveTimeSchedule() {
    if (startTime != null && endTime != null) {
      String startTimeString = DateFormat.Hm().format(
        DateTime(0, 0, 0, startTime!.hour, startTime!.minute),
      );
      String endTimeString = DateFormat.Hm().format(
        DateTime(0, 0, 0, endTime!.hour, endTime!.minute),
      );

      // Prepare time slots for the request
      List<Map<String, String>> timeSlots = [
        {'start_time': startTimeString, 'end_time': endTimeString}
      ];

      // Use your service to save the schedule
      AppToggleService().saveTimeSchedule(
        widget.appName,
        widget.childId,
        timeSlots,
      ).then((_) {
        // Close the dialog if successful
        Navigator.of(context).pop();
      }).catchError((error) {
        // Show an error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving schedule: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end times')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      backgroundColor: Colors.white, // Solid white background
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor, width: 2), // Border matching app bar color
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red), // Red X button
            padding: const EdgeInsets.all(0), // Reduce padding
            iconSize: 32, // Thicker icon size
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Flexible(
            child: Text(
              'Set Time Schedule for ${widget.appName}',
              style: const TextStyle(
                fontSize: 20.0, // Larger font for the title
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black for the title text
                fontFamily: 'Georgia', // Using the app's theme font
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.check, color: appBarColor), // Check button with appBarColor
            padding: const EdgeInsets.all(0), // Reduce padding
            iconSize: 32, // Thicker icon size
            onPressed: saveTimeSchedule,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Start Time',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectTime(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White background for the button
                  side: BorderSide(color: appBarColor), // Border matching app bar color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  startTime != null ? startTime!.format(context) : 'Set Time', // Updated button text
                  style: TextStyle(
                    color: appBarColor,
                    fontSize: 18, // Larger font size
                    fontWeight: FontWeight.bold, // Bold font style
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'End Time',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectTime(context, false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: appBarColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  endTime != null ? endTime!.format(context) : 'Set Time', // Updated button text
                  style: TextStyle(
                    color: appBarColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Add spacing between sections

          // Display the dialog prompt below the end time
          ElevatedButton(
  onPressed: () {
    DialogPrompt.show(context); // Show the dialog with information
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: appBarColor, // Correct parameter for button background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text(
    'App Time Schedule Info',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white, // White text color
    ),
  ),
)

        ],
      ),
    );
  }
}*/