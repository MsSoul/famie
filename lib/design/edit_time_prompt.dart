//filename:design/edit_time_prompt.dart(for editing screen time schedule)
///filename: design/edit_time_prompt.dart (for editing screen time schedule)
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class EditTimePromptDialog extends StatefulWidget {
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;
  final Function(TimeOfDay?, TimeOfDay?) onSave;
  final String childId;

  const EditTimePromptDialog({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.onSave,
    required this.childId,
  });

  @override
  EditTimePromptDialogState createState() => EditTimePromptDialogState();
}

class EditTimePromptDialogState extends State<EditTimePromptDialog> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime! : _endTime!,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green,
              onPrimary: Colors.white, // Button text color
              onSurface: Colors.black, // Dialog surface color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEditedSchedule() {
    if (_startTime != null && _endTime != null) {
      widget.onSave(_startTime, _endTime);
      Navigator.of(context).pop(); // Close dialog after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end times'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(8.0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: appBarColor, width: 2),
      ),
      titlePadding: const EdgeInsets.only(top: 5.0), // Minimal margin for the title
      title: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              iconSize: 32,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const Center(
            child: Text(
              'Edit Time Slot',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.check, color: appBarColor),
              iconSize: 32,
              onPressed: _saveEditedSchedule,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background remains white
                  side: BorderSide(color: appBarColor, width: 2), // Border color with appBarColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                ),
                onPressed: () {
                  _selectTime(context, true);
                },
                child: Text(
                  _startTime != null ? _startTime!.format(context) : 'Set Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appBarColor),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background remains white
                  side: BorderSide(color: appBarColor, width: 2), // Border color with appBarColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                ),
                onPressed: () {
                  _selectTime(context, false);
                },
                child: Text(
                  _endTime != null ? _endTime!.format(context) : 'Set Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appBarColor),
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
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class EditTimePromptDialog extends StatefulWidget {
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;
  final Function(TimeOfDay?, TimeOfDay?) onSave;
  final String childId;

  const EditTimePromptDialog({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.onSave,
    required this.childId,
  });

  @override
  EditTimePromptDialogState createState() => EditTimePromptDialogState();
}

class EditTimePromptDialogState extends State<EditTimePromptDialog> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime! : _endTime!,
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
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEditedSchedule() {
    if (_startTime != null && _endTime != null) {
      widget.onSave(_startTime, _endTime);
      Navigator.of(context).pop(); // Close dialog after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end times'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(8.0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: appBarColor, width: 2),
      ),
      titlePadding: const EdgeInsets.only(top: 5.0), // Minimal margin for the title
      title: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              iconSize: 32,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const Center(
            child: Text(
              'Edit Time Slot',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.check, color: appBarColor),
              iconSize: 32,
              onPressed: _saveEditedSchedule,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background remains white
                  side: BorderSide(color: appBarColor, width: 2), // Border color with appBarColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                ),
                onPressed: () {
                  _selectTime(context, true);
                },
                child: Text(
                  _startTime != null ? _startTime!.format(context) : 'Set Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appBarColor),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background remains white
                  side: BorderSide(color: appBarColor, width: 2), // Border color with appBarColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                ),
                onPressed: () {
                  _selectTime(context, false);
                },
                child: Text(
                  _endTime != null ? _endTime!.format(context) : 'Set Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appBarColor),
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

/*working without design lage
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class EditTimePromptDialog extends StatefulWidget {
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;
  final Function(TimeOfDay?, TimeOfDay?) onSave;
  final String childId;

  const EditTimePromptDialog({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.onSave,
    required this.childId,
  });

  @override
  EditTimePromptDialogState createState() => EditTimePromptDialogState();
}

class EditTimePromptDialogState extends State<EditTimePromptDialog> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime! : _endTime!,
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
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEditedSchedule() {
    if (_startTime != null && _endTime != null) {
      widget.onSave(_startTime, _endTime);
      Navigator.of(context).pop(); // Close dialog after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end times'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

    return AlertDialog(
      contentPadding: const EdgeInsets.all(8.0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: appBarColor, width: 2),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            iconSize: 32,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Flexible(
            child: Text(
              'Edit Time Slot',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.check, color: appBarColor),
            iconSize: 32,
            onPressed: _saveEditedSchedule,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectTime(context, true);
                },
                child: Text(
                  _startTime != null ? _startTime!.format(context) : 'Set Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appBarColor),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectTime(context, false);
                },
                child: Text(
                  _endTime != null ? _endTime!.format(context) : 'Set Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appBarColor),
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