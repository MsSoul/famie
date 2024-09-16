import 'package:flutter/material.dart';
import '../services/child_database_service.dart';

class ScreenTimeScheduleDialog extends StatefulWidget {
  final List<Map<String, TimeOfDay>> schedules;
  final Function(TimeOfDay?, TimeOfDay?) onAddSchedule;
  final Function(int, TimeOfDay?, TimeOfDay?) onEditSchedule;

  const ScreenTimeScheduleDialog({
    super.key,
    required this.schedules,
    required this.onAddSchedule,
    required this.onEditSchedule,
  });

  @override
  ScreenTimeScheduleDialogState createState() => ScreenTimeScheduleDialogState();
}

class ScreenTimeScheduleDialogState extends State<ScreenTimeScheduleDialog> {
  List<Map<String, TimeOfDay>> _schedules = [];
  Duration _totalScreenTime = Duration.zero;
  DatabaseService dbHelper = DatabaseService();

  @override
  void initState() {
    super.initState();
    _schedules = List.from(widget.schedules);
    _calculateTotalScreenTime();
  }

  void _calculateTotalScreenTime() {
    _totalScreenTime = Duration.zero;
    for (var schedule in _schedules) {
      final start = schedule['start']!;
      final end = schedule['end']!;
      final difference = end.hour * 60 + end.minute - (start.hour * 60 + start.minute);
      _totalScreenTime += Duration(minutes: difference);
    }
  }

  void _addSchedule(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime != null && endTime != null) {
      setState(() {
        _schedules.add({'start': startTime, 'end': endTime});
        _calculateTotalScreenTime();
      });
      widget.onAddSchedule(startTime, endTime);
    }
  }

  void _editSchedule(int index, TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime != null && endTime != null) {
      setState(() {
        _schedules[index] = {'start': startTime, 'end': endTime};
        _calculateTotalScreenTime();
      });
      widget.onEditSchedule(index, startTime, endTime);
    }
  }

  Future<void> _saveSchedules() async {
    List<Map<String, String>> schedules = _schedules.map((schedule) {
      return {
        'start': schedule['start']!.format(context),
        'end': schedule['end']!.format(context),
      };
    }).toList();
    await dbHelper.saveTimeManagement(schedules, _totalScreenTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                onPressed: () {
                  _saveSchedules();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const Divider(color: Colors.green), // Moved closer to the text
          const SizedBox(height: 5), // Adjusted spacing here
          ..._schedules.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, TimeOfDay> schedule = entry.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(value: true, onChanged: (value) {}),
                ),
                Expanded(
                  child: Text(
                    '${schedule['start']!.format(context)} - ${schedule['end']!.format(context)}',
                    style: const TextStyle(color: Colors.green, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 10), // Space between time and edit button
                SizedBox(
                  height: 24,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddTimeScheduleDialog(
                            initialStartTime: schedule['start'],
                            initialEndTime: schedule['end'],
                            onAddSchedule: (startTime, endTime) {
                              _editSchedule(index, startTime, endTime);
                            },
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),
          Center(
            child: IconButton(
              icon: const Icon(Icons.add_circle),
              iconSize: 60.0,
              color: Colors.green[200],
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddTimeScheduleDialog(
                      onAddSchedule: (startTime, endTime) {
                        _addSchedule(startTime, endTime);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Total Screen Time: ${_totalScreenTime.inHours}h ${_totalScreenTime.inMinutes.remainder(60)}m',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AddTimeScheduleDialog extends StatefulWidget {
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final Function(TimeOfDay?, TimeOfDay?) onAddSchedule;

  const AddTimeScheduleDialog({super.key, this.initialStartTime, this.initialEndTime, required this.onAddSchedule});

  @override
  AddTimeScheduleDialogState createState() => AddTimeScheduleDialogState();
}

class AddTimeScheduleDialogState extends State<AddTimeScheduleDialog> {
  TimeOfDay? _beginningTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _beginningTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  Future<void> _selectTime(BuildContext context, bool isBeginningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color (clock numbers)
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // button text color
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Colors.white,
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) => Colors.black), // Clock numbers
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                states.contains(WidgetState.selected) ? Colors.white : Colors.black, // AM/PM text color
              ),
              dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                states.contains(WidgetState.selected) ? Colors.green : Colors.transparent, // AM/PM highlight color
              ),
            ),
            dialogBackgroundColor: Colors.black.withOpacity(0.5), // semi-transparent background
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != (_beginningTime ?? _endTime)) {
      setState(() {
        if (isBeginningTime) {
          _beginningTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
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
              'Set Time Schedule',
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
            onPressed: () {
              widget.onAddSchedule(_beginningTime, _endTime);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.green, thickness: 1.0), // Moved closer to the text
          const SizedBox(height: 5), // Adjusted spacing here
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                _beginningTime != null
                    ? _beginningTime!.format(context)
                    : 'Beginning Time',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10), // Adjusted spacing here
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                _endTime != null
                    ? _endTime!.format(context)
                    : 'End Time',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
