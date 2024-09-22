//filename:set_time_limit/time_schedule_dialog
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // Import logger for debugging
import '../services/time_service.dart'; // Make sure you import your TimeService

final Logger logger = Logger(); // Initialize logger

class ScreenTimeScheduleDialog extends StatefulWidget {
  final List<Map<String, TimeOfDay>> schedules;
  final Function(TimeOfDay?, TimeOfDay?) onAddSchedule;
  final Function(int, TimeOfDay?, TimeOfDay?) onEditSchedule;
  final String childId;

  const ScreenTimeScheduleDialog({
    super.key,
    required this.schedules,
    required this.onAddSchedule,
    required this.onEditSchedule,
    required this.childId,
  });

  @override
  ScreenTimeScheduleDialogState createState() =>
      ScreenTimeScheduleDialogState();
}

class ScreenTimeScheduleDialogState extends State<ScreenTimeScheduleDialog> {
  TimeOfDay? _beginningTime;
  TimeOfDay? _endTime;

  // Function to select time
  Future<void> _selectTime(BuildContext context, bool isBeginningTime) async {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select time", // Add your custom label here
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child!, // Keep the child widget here (the time picker itself)
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBeginningTime) {
          _beginningTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // Save function when check button is pressed
  void _saveSchedule() {
    logger.i('Check button pressed!'); // Log the button press

    if (_beginningTime != null && _endTime != null) {
      // Adding schedule to the parent widget
      widget.onAddSchedule(_beginningTime, _endTime);

      // Prepare the data to save via TimeService in 24-hour format
      List<Map<String, String>> timeSlots = [
        {
          'start_time':
              '${_beginningTime!.hour.toString().padLeft(2, '0')}:${_beginningTime!.minute.toString().padLeft(2, '0')}',
          'end_time':
              '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        }
      ];

      // Log the timeSlots for debugging
      logger.i('Time Slots prepared: $timeSlots');

      // Call the TimeService to save the schedule
      TimeService().saveTimeManagement(widget.childId, timeSlots).then((_) {
        logger.i('Schedule saved successfully!');
        // Close the dialog after saving successfully
        Navigator.of(context).pop();
      }).catchError((error) {
        logger.e('Error saving schedule: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error saving schedule. Please try again.')),
        );
      });
    } else {
      // Show an error if times are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both beginning and end times')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Fixed margin for flexibility
      backgroundColor: Colors.white, // Solid white background
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor, width: 2), // Border matching app bar color
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: const EdgeInsets.only(top: 5.0), // Minimal margin for the title
      title: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red), // Red X button
              padding: const EdgeInsets.all(0), // Remove padding
              iconSize: 32, // Larger icon size
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const Center(
            child: Text(
              'Set Screen Time\nSchedule', 
              style: TextStyle(
                fontSize: 20.0, 
                fontWeight: FontWeight.bold,
                color: Colors.black, 
                fontFamily: 'Georgia',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.check, color: appBarColor), // Check button with appBarColor
              padding: const EdgeInsets.all(0), // Remove padding
              iconSize: 32, // Larger icon size
              onPressed: _saveSchedule,
            ),
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
                  _beginningTime != null
                      ? _beginningTime!.format(context)
                      : 'Set Time',
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
                  _endTime != null ? _endTime!.format(context) : 'Set Time',
                  style: TextStyle(
                    color: appBarColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*// filename: set_time_limit/time_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // Import logger for debugging
import '../services/time_service.dart'; // Make sure you import your TimeService

final Logger logger = Logger(); // Initialize logger

class ScreenTimeScheduleDialog extends StatefulWidget {
  final List<Map<String, TimeOfDay>> schedules;
  final Function(TimeOfDay?, TimeOfDay?) onAddSchedule;
  final Function(int, TimeOfDay?, TimeOfDay?) onEditSchedule;
  final String childId;

  const ScreenTimeScheduleDialog({
    super.key,
    required this.schedules,
    required this.onAddSchedule,
    required this.onEditSchedule,
    required this.childId,
  });

  @override
  ScreenTimeScheduleDialogState createState() =>
      ScreenTimeScheduleDialogState();
}

class ScreenTimeScheduleDialogState extends State<ScreenTimeScheduleDialog> {
  TimeOfDay? _beginningTime;
  TimeOfDay? _endTime;

  // Function to select time
  Future<void> _selectTime(BuildContext context, bool isBeginningTime) async {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select time", // Add your custom label here
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child!, // Keep the child widget here (the time picker itself)
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBeginningTime) {
          _beginningTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // Save function when the check button is pressed
  void _saveSchedule() {
    logger.i('Check button pressed!');

    if (_beginningTime != null && _endTime != null) {
      // Prepare the data to save via TimeService in 24-hour format
      List<Map<String, String>> timeSlots = [
        {
          'start_time':
              '${_beginningTime!.hour.toString().padLeft(2, '0')}:${_beginningTime!.minute.toString().padLeft(2, '0')}',
          'end_time':
              '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        }
      ];

      // Call the TimeService to save the schedule
      TimeService().saveTimeManagement(widget.childId, timeSlots).then((_) {
        logger.i('Schedule saved successfully!');

        // Call the parent callback to update the schedule in TimeManagement
        widget.onAddSchedule(_beginningTime, _endTime);

        // Close the dialog after saving successfully
        Navigator.of(context).pop();
      }).catchError((error) {
        logger.e('Error saving schedule: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving schedule. Please try again.')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both beginning and end times')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

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
            padding: const EdgeInsets.all(0), // Remove padding
            iconSize: 32, // Thicker icon size
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Flexible(
            child: Text(
              'Set Screen Time Schedule',
              style: TextStyle(
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
            padding: const EdgeInsets.all(0), // Remove padding
            iconSize: 32, // Thicker icon size
            onPressed: _saveSchedule,
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
                  _beginningTime != null
                      ? _beginningTime!.format(context)
                      : 'Set Time',
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
                  _endTime != null ? _endTime!.format(context) : 'Set Time',
                  style: TextStyle(
                    color: appBarColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

*/
/*
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';  // Import logger for debugging
import '../services/time_service.dart';  // Make sure you import your TimeService

final Logger logger = Logger();  // Initialize logger

class ScreenTimeScheduleDialog extends StatefulWidget {
  final List<Map<String, TimeOfDay>> schedules;
  final Function(TimeOfDay?, TimeOfDay?) onAddSchedule;
  final Function(int, TimeOfDay?, TimeOfDay?) onEditSchedule;
  final String childId;

  const ScreenTimeScheduleDialog({
    super.key,
    required this.schedules,
    required this.onAddSchedule,
    required this.onEditSchedule,
    required this.childId,
  });

  @override
  ScreenTimeScheduleDialogState createState() => ScreenTimeScheduleDialogState();
}

class ScreenTimeScheduleDialogState extends State<ScreenTimeScheduleDialog> {
  TimeOfDay? _beginningTime;
  TimeOfDay? _endTime;

  // Function to select time
  Future<void> _selectTime(BuildContext context, bool isBeginningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
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
        if (isBeginningTime) {
          _beginningTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // Save function when check button is pressed
  void _saveSchedule() {
    logger.i('Check button pressed!');  // Log the button press

    if (_beginningTime != null && _endTime != null) {
      // Adding schedule to the parent widget
      widget.onAddSchedule(_beginningTime, _endTime);

      // Prepare the data to save via TimeService in 24-hour format
List<Map<String, String>> timeSlots = [
  {
    'start_time': '${_beginningTime!.hour.toString().padLeft(2, '0')}:${_beginningTime!.minute.toString().padLeft(2, '0')}',
    'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
  }
];


      // Log the timeSlots for debugging
      logger.i('Time Slots prepared: $timeSlots');

      // Call the TimeService to save the schedule
      TimeService().saveTimeManagement(widget.childId, timeSlots).then((_) {
        logger.i('Schedule saved successfully!');
        // Close the dialog after saving successfully
        Navigator.of(context).pop();
      }).catchError((error) {
        logger.e('Error saving schedule: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving schedule. Please try again.')),
        );
      });

    } else {
      // Show an error if times are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both beginning and end times')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return AlertDialog(
    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Reduce padding to make it more compact
    backgroundColor: Colors.green[50],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Flexible(
          child: Text(
            'Set Screen Time Schedule',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: _saveSchedule,  // Call the save function when check is pressed
        ),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            _selectTime(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _beginningTime != null ? _beginningTime!.format(context) : 'Beginning Time',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _selectTime(context, false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _endTime != null ? _endTime!.format(context) : 'End Time',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
}

*/