//filename:design/app_toggle_prompt.dart(setting app time schedule)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_toggle_service.dart'; // Import your service
import 'dialog_prompt.dart'; // Import the Dialog Prompt widget
import 'package:logger/logger.dart';


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

    // Check if the schedule is valid
    if (!_isScheduleValid(startTime!, endTime!)) {
      DialogPrompt.showInvalidSchedule(context); // Show the invalid schedule prompt
      return; // Exit the method if the schedule is invalid
    }

    // Prepare time slots for the request
    List<Map<String, String>> timeSlots = [
      {'start_time': startTimeString, 'end_time': endTimeString}
    ];

    // Show a loading indicator or prompt before saving
    DialogPrompt.showSuccess(context); // Optional: Show a loading prompt
    Navigator.of(context).pop();
    
    // Use your service to save the schedule
    AppToggleService().saveTimeSchedule(
      widget.appName,
      widget.childId,
      timeSlots,
    ).then((_) {
      // Log successful save action
      logger.i('Time schedule saved successfully.'); // Replace print with logger
      Navigator.of(context).pop(); // Close the loading prompt
      DialogPrompt.showSuccess(context); // Show success prompt after saving
      Navigator.of(context).pop(); // Close the dialog again if needed
    }).catchError((error) {
      // Log error if something goes wrong
      logger.e('Error saving schedule: $error'); // Replace print with logger
      Navigator.of(context).pop(); // Close the loading prompt
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



  bool _isScheduleValid(TimeOfDay start, TimeOfDay end) {
    // Define your allowed time ranges (example: 9 AM to 5 PM)
    const allowedStart = TimeOfDay(hour: 9, minute: 0); // 9:00 AM
    const allowedEnd = TimeOfDay(hour: 17, minute: 0); // 5:00 PM

    // Check if the selected times are within the allowed range
    final startInRange = start.hour > allowedStart.hour || 
                         (start.hour == allowedStart.hour && start.minute >= allowedStart.minute);
    final endInRange = end.hour < allowedEnd.hour || 
                       (end.hour == allowedEnd.hour && end.minute <= allowedEnd.minute);
    
    return startInRange && endInRange && (end.hour > start.hour || 
           (end.hour == start.hour && end.minute > start.minute)); // Ensure end time is after start time
  }

  void _showSuccessPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Success',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Congratulations! The time schedule has been successfully added.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.green, width: 2),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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