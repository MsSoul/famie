import 'package:flutter/material.dart';
import '../set_time_limit/time_schedule_dialog.dart';
import '../services/child_database_service.dart';

class TimeManagement extends StatelessWidget {
  const TimeManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Total Screen Time Limit',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 10),
        const TimeLimitWidget(),
      ],
    );
  }
}

class TimeLimitWidget extends StatefulWidget {
  const TimeLimitWidget({super.key});

  @override
  TimeLimitWidgetState createState() => TimeLimitWidgetState();
}

class TimeLimitWidgetState extends State<TimeLimitWidget> {
  final List<Map<String, TimeOfDay>> _schedules = [];
  Duration _totalScreenTime = Duration.zero;
  DatabaseService dbHelper = DatabaseService();

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
    }
  }

  void _editSchedule(int index, TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime != null && endTime != null) {
      setState(() {
        _schedules[index] = {'start': startTime, 'end': endTime};
        _calculateTotalScreenTime();
      });
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TimeInputField(
              label: 'Hour/s',
              value: _totalScreenTime.inHours.toString().padLeft(2, '0'),
            ),
            const Text(
              ':',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            TimeInputField(
              label: 'Minute/s',
              value: (_totalScreenTime.inMinutes.remainder(60)).toString().padLeft(2, '0'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ScreenTimeScheduleDialog(
                      schedules: _schedules,
                      onAddSchedule: _addSchedule,
                      onEditSchedule: _editSchedule,
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255), // background color
              ),
              child: const Text('Edit', style: TextStyle(color: Colors.black)), // text color
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _saveSchedules,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255), // background color
              ),
              child: const Text('Save', style: TextStyle(color: Colors.black)), // text color
            ),
          ],
        ),
      ],
    );
  }
}

class TimeInputField extends StatelessWidget {
  final String label;
  final String value;

  const TimeInputField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
