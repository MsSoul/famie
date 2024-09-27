//filename:set_time_limit/time_schedule_dialog
//filename:set_time_limit/time_schedule_dialog
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/time_service.dart';
import '../design/notification_prompts.dart';

final Logger logger = Logger();

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
    logger.i('Check button pressed!');

    if (_beginningTime != null && _endTime != null) {
      // Create a new schedule
      final newSchedule = {
        'start_time': '${_beginningTime!.hour.toString().padLeft(2, '0')}:${_beginningTime!.minute.toString().padLeft(2, '0')}',
        'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        'is_allowed': 'true',
      };

      // Check if the new time slot is a duplicate
      List<Map<String, String>> updatedTimeSlots = widget.schedules.map((slot) {
        return {
          'start_time': '${slot['start_time']!.hour.toString().padLeft(2, '0')}:${slot['start_time']!.minute.toString().padLeft(2, '0')}',
          'end_time': '${slot['end_time']!.hour.toString().padLeft(2, '0')}:${slot['end_time']!.minute.toString().padLeft(2, '0')}',
          'is_allowed': 'true',
        };
      }).toList();

      // Prevent duplicate time slots from being added
      if (_isDuplicateTimeSlot(newSchedule, updatedTimeSlots)) {
        showErrorNotification(context, 'Duplicate time slot detected. Please choose a different time.');
        return;
      }

      // Log only the new schedule to save
      logger.i('New Time Slot to be saved: $newSchedule');

      // Call TimeService to save only the new time slot
      TimeService().saveTimeManagement(widget.childId, [newSchedule]).then((_) {
        logger.i('New schedule saved successfully!');

        // Notify the parent about the new schedule
        widget.onAddSchedule(_beginningTime, _endTime);

        // Show the success prompt with callback to refresh after closing
        addTimeSuccessPrompt(context, onPromptClosed: () {
          Navigator.of(context).pop(); // Close the schedule dialog after success
        });

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

  // Helper method to check for duplicate time slots
  bool _isDuplicateTimeSlot(Map<String, String> newSlot, List<Map<String, String>> existingSlots) {
    for (var slot in existingSlots) {
      if (slot['start_time'] == newSlot['start_time'] && slot['end_time'] == newSlot['end_time']) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicate
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0), 
      backgroundColor: Colors.white, 
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor, width: 2),
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: const EdgeInsets.only(top: 5.0),
      title: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
              icon: Icon(Icons.check, color: appBarColor),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
                  backgroundColor: Colors.white,
                  side: BorderSide(color: appBarColor),
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

/*
// filename: set_time_limit/time_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/time_service.dart';
import '../design/notification_prompts.dart';

final Logger logger = Logger();

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
    logger.i('Check button pressed!');

    if (_beginningTime != null && _endTime != null) {
      // Create a new schedule
      final newSchedule = {
        'start_time': '${_beginningTime!.hour.toString().padLeft(2, '0')}:${_beginningTime!.minute.toString().padLeft(2, '0')}',
        'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        'is_allowed': 'true',
      };

      // Check if the new time slot is a duplicate
      List<Map<String, String>> updatedTimeSlots = widget.schedules.map((slot) {
        return {
          'start_time': '${slot['start_time']!.hour.toString().padLeft(2, '0')}:${slot['start_time']!.minute.toString().padLeft(2, '0')}',
          'end_time': '${slot['end_time']!.hour.toString().padLeft(2, '0')}:${slot['end_time']!.minute.toString().padLeft(2, '0')}',
          'is_allowed': 'true',
        };
      }).toList();

      // Prevent duplicate time slots from being added
      if (_isDuplicateTimeSlot(newSchedule, updatedTimeSlots)) {
        showErrorNotification(context, 'Duplicate time slot detected. Please choose a different time.');
        return;
      }

      // Add the new time slot
      updatedTimeSlots.add(newSchedule);

      logger.i('Updated Time Slots to be saved: $updatedTimeSlots');

      // Call TimeService to save the time slots
      TimeService().saveTimeManagement(widget.childId, updatedTimeSlots).then((_) {
        logger.i('Schedule saved successfully!');

        // Notify the parent about the new schedule
        widget.onAddSchedule(_beginningTime, _endTime);

        // Show the success prompt with callback to refresh after closing
        addTimeSuccessPrompt(context, onPromptClosed: () {
          Navigator.of(context).pop(); // Close the schedule dialog after success
        });

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

  // Helper method to check for duplicate time slots
  bool _isDuplicateTimeSlot(Map<String, String> newSlot, List<Map<String, String>> existingSlots) {
    for (var slot in existingSlots) {
      if (slot['start_time'] == newSlot['start_time'] && slot['end_time'] == newSlot['end_time']) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicate
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0), 
      backgroundColor: Colors.white, 
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor, width: 2),
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: const EdgeInsets.only(top: 5.0),
      title: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
              icon: Icon(Icons.check, color: appBarColor),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
                  backgroundColor: Colors.white,
                  side: BorderSide(color: appBarColor),
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
import 'package:logger/logger.dart';
import '../services/time_service.dart';
import '../design/notification_prompts.dart';

final Logger logger = Logger();

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
    logger.i('Check button pressed!');

    if (_beginningTime != null && _endTime != null) {
      // Append new time slot to the existing schedules
      List<Map<String, String>> timeSlots = widget.schedules.map((slot) {
        return {
          'start_time': '${slot['start_time']!.hour.toString().padLeft(2, '0')}:${slot['start_time']!.minute.toString().padLeft(2, '0')}',
          'end_time': '${slot['end_time']!.hour.toString().padLeft(2, '0')}:${slot['end_time']!.minute.toString().padLeft(2, '0')}',
          'is_allowed': 'true',
        };
      }).toList();

      // Add the newly selected time slot to the list
      final newSchedule = {
        'start_time': '${_beginningTime!.hour.toString().padLeft(2, '0')}:${_beginningTime!.minute.toString().padLeft(2, '0')}',
        'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        'is_allowed': 'true',
      };
      
      timeSlots.add(newSchedule);

      logger.i('Updated Time Slots to be saved: $timeSlots');

      // Call TimeService to save the time slots
      TimeService().saveTimeManagement(widget.childId, timeSlots).then((_) {
        logger.i('Schedule saved successfully!');

        // Notify the parent about the new schedule
        widget.onAddSchedule(_beginningTime, _endTime);

        // Show the success prompt with callback to refresh after closing
        addTimeSuccessPrompt(context, onPromptClosed: () {
          Navigator.of(context).pop(); // Close the schedule dialog after success
        });

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0), 
      backgroundColor: Colors.white, 
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor, width: 2),
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: const EdgeInsets.only(top: 5.0),
      title: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
              icon: Icon(Icons.check, color: appBarColor),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
                  backgroundColor: Colors.white,
                  side: BorderSide(color: appBarColor),
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
// filename: set_time_limit/time_schedule_dialog
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/time_service.dart';
import '../design/notification_prompts.dart';

final Logger logger = Logger();

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
  // Save function when check button is pressed
void _saveSchedule() {
  logger.i('Check button pressed!');

  if (_beginningTime != null && _endTime != null) {
    // Append new time slot to the existing schedules
    List<Map<String, String>> timeSlots = widget.schedules.map((slot) {
      return {
        'start_time': '${slot['start_time']!.hour.toString().padLeft(2, '0')}:${slot['start_time']!.minute.toString().padLeft(2, '0')}',
        'end_time': '${slot['end_time']!.hour.toString().padLeft(2, '0')}:${slot['end_time']!.minute.toString().padLeft(2, '0')}',
        'is_allowed': 'true',
      };
    }).toList();

    // Add the newly selected time slot to the list
    timeSlots.add({
      'start_time': '${_beginningTime!.hour.toString().padLeft(2, '0')}:${_beginningTime!.minute.toString().padLeft(2, '0')}',
      'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
      'is_allowed': 'true', 
    });

    logger.i('Updated Time Slots to be saved: $timeSlots');

    // Call TimeService to save the time slots
    TimeService().saveTimeManagement(widget.childId, timeSlots).then((_) {
      logger.i('Schedule saved successfully!');

      // Show the success prompt with callback to refresh after closing
      addTimeSuccessPrompt(context, onPromptClosed: () {
        Navigator.of(context).pop(); // Close the schedule dialog after success
      });

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0), 
      backgroundColor: Colors.white, 
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor, width: 2),
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: const EdgeInsets.only(top: 5.0),
      title: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
              icon: Icon(Icons.check, color: appBarColor),
              padding: const EdgeInsets.all(0),
              iconSize: 32,
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
                  backgroundColor: Colors.white,
                  side: BorderSide(color: appBarColor),
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
}*/