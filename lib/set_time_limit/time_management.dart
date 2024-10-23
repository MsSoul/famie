// filename: time_management.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import '../services/time_service.dart';
import 'time_schedule_dialog.dart';
import '../design/edit_time_prompt.dart'; // Import for editing time dialog
import '../design/notification_prompts.dart'; // Import for prompts

final Logger logger = Logger();

class TimeManagement extends StatefulWidget {
  final String childId;

  const TimeManagement({super.key, required this.childId});

  @override
  TimeManagementState createState() => TimeManagementState();
}

class TimeManagementState extends State<TimeManagement> {
  List<Map<String, String>> timeSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots(); // Fetch the initial time slots when the screen loads
  }

  @override
  void didUpdateWidget(covariant TimeManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _fetchTimeSlots(); // Fetch new time slots if the childId changes
    }
  }

  // Fetch time slots from the backend for the selected child
  // Fetch time slots from the backend for the selected child
Future<void> _fetchTimeSlots() async {
  try {
    // Clear the current time slots before fetching new ones
    setState(() {
      timeSlots.clear();
    });

    List<Map<String, dynamic>> fetchedTimeSlots = await TimeService().fetchTimeSlots(widget.childId);

    setState(() {
      timeSlots = fetchedTimeSlots.map((timeSlot) {
        return {
          'start_time': timeSlot['start_time'].toString(),
          'end_time': timeSlot['end_time'].toString(),
          'is_allowed': timeSlot['is_allowed'].toString(),
        };
      }).toList();
    });
  } catch (e) {
    logger.e('Error fetching time slots: $e');
  }
}



  // Callback to handle adding a new schedule
  void _onAddSchedule(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime != null && endTime != null) {
      setState(() {
        timeSlots.add({
          'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          'is_allowed': 'true',
        });
      });
    }
  }
  // Convert 24-hour time format to 12-hour with AM/PM
  String _formatTime(String time) {
    DateTime dateTime = DateFormat.Hm().parse(time); // Parse the time string in 24-hour format
    return DateFormat.jm().format(dateTime); // Convert to 12-hour format with AM/PM
  }

  // Delete a time slot with confirmation prompt
  void _deleteTimeSlot(int index) async {
    showDeleteConfirmationPrompt(context, () async {
      try {
        await TimeService().deleteTimeSlot(widget.childId, index);
        setState(() {
          timeSlots.removeAt(index);
        });
      } catch (e) {
        logger.e('Error deleting time slot: $e');
      }
    });
  }

  // Toggle allowed status
  void _toggleAllowedStatus(int index) async {
    bool isAllowed = timeSlots[index]['is_allowed'] == 'true';

    if (isAllowed) {
      showToggleConfirmationPrompt(context, () async {
        await TimeService().toggleAllowedStatus(context, widget.childId, index, false);
        setState(() {
          timeSlots[index]['is_allowed'] = 'false';
        });
      });
    } else {
      // Automatically turn on the schedule without notification
      await TimeService().toggleAllowedStatus(context, widget.childId, index, true);
      setState(() {
        timeSlots[index]['is_allowed'] = 'true';
      });
    }
  }

  // Edit an existing time slot using TimeService
  Future<void> _editTimeSlot(int index) async {
    final startTime = TimeOfDay(
      hour: int.parse(timeSlots[index]['start_time']!.split(':')[0]),
      minute: int.parse(timeSlots[index]['start_time']!.split(':')[1]),
    );

    final endTime = TimeOfDay(
      hour: int.parse(timeSlots[index]['end_time']!.split(':')[0]),
      minute: int.parse(timeSlots[index]['end_time']!.split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTimePromptDialog(
          initialStartTime: startTime,
          initialEndTime: endTime,
          childId: widget.childId,
          onSave: (newStartTime, newEndTime) async {
            if (newStartTime != null && newEndTime != null) {
              try {
                await TimeService().updateTimeSlot(widget.childId, index, newStartTime, newEndTime);
                _fetchTimeSlots(); // Refresh after editing
              } catch (e) {
                logger.e('Error updating time slot: $e');
              }
            }
          },
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
  final TextStyle fontStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 18, // Larger font size
  );

  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: appBarColor,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: const Center(
            child: Text(
              'Set Daily Screen Time Schedule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = timeSlots[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.8, // Reduce the size of the toggle switch (0.8 makes it 80% of its original size)
                      child: Switch(
                        value: timeSlot['is_allowed'] == 'true',
                        onChanged: (value) {
                          _toggleAllowedStatus(index); // Toggle the allowed status
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[400],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        '${_formatTime(timeSlot['start_time']!)} - ${_formatTime(timeSlot['end_time']!)}',
                        style: fontStyle,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: appBarColor, size: 24),
                      onPressed: () {
                        _editTimeSlot(index); // Edit time slot on button click
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: appBarColor, size: 24),
                      onPressed: () {
                        _deleteTimeSlot(index); // Delete time slot on button click
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ScreenTimeScheduleDialog(
                    schedules: timeSlots.map((slot) {
                      return {
                        'start_time': TimeOfDay(
                          hour: int.parse(slot['start_time']!.split(':')[0]),
                          minute: int.parse(slot['start_time']!.split(':')[1]),
                        ),
                        'end_time': TimeOfDay(
                          hour: int.parse(slot['end_time']!.split(':')[0]),
                          minute: int.parse(slot['end_time']!.split(':')[1]),
                        ),
                      };
                    }).toList(),
                    childId: widget.childId,
                    onAddSchedule: _onAddSchedule,
                    onEditSchedule: (int index, TimeOfDay? startTime, TimeOfDay? endTime) {
                      // Handle edit schedule
                    },
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appBarColor,
            ),
            child: const Icon(Icons.add),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Total Set Schedules: ${timeSlots.length}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appBarColor),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

}
/* e modify kay magbutang ug no child added yet
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import '../services/time_service.dart';
import 'time_schedule_dialog.dart';
import '../design/edit_time_prompt.dart'; // Import for editing time dialog
import '../design/notification_prompts.dart'; // Import for prompts

final Logger logger = Logger();

class TimeManagement extends StatefulWidget {
  final String childId;

  const TimeManagement({super.key, required this.childId});

  @override
  TimeManagementState createState() => TimeManagementState();
}

class TimeManagementState extends State<TimeManagement> {
  List<Map<String, String>> timeSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots(); // Fetch the initial time slots when the screen loads
  }

  @override
  void didUpdateWidget(covariant TimeManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _fetchTimeSlots(); // Fetch new time slots if the childId changes
    }
  }

  // Fetch time slots from the backend for the selected child
  // Fetch time slots from the backend for the selected child
Future<void> _fetchTimeSlots() async {
  try {
    // Clear the current time slots before fetching new ones
    setState(() {
      timeSlots.clear();
    });

    List<Map<String, dynamic>> fetchedTimeSlots = await TimeService().fetchTimeSlots(widget.childId);

    setState(() {
      timeSlots = fetchedTimeSlots.map((timeSlot) {
        return {
          'start_time': timeSlot['start_time'].toString(),
          'end_time': timeSlot['end_time'].toString(),
          'is_allowed': timeSlot['is_allowed'].toString(),
        };
      }).toList();
    });
  } catch (e) {
    logger.e('Error fetching time slots: $e');
  }
}



  // Callback to handle adding a new schedule
  void _onAddSchedule(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime != null && endTime != null) {
      setState(() {
        timeSlots.add({
          'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          'is_allowed': 'true',
        });
      });
    }
  }
  // Convert 24-hour time format to 12-hour with AM/PM
  String _formatTime(String time) {
    DateTime dateTime = DateFormat.Hm().parse(time); // Parse the time string in 24-hour format
    return DateFormat.jm().format(dateTime); // Convert to 12-hour format with AM/PM
  }

  // Delete a time slot with confirmation prompt
  void _deleteTimeSlot(int index) async {
    showDeleteConfirmationPrompt(context, () async {
      try {
        await TimeService().deleteTimeSlot(widget.childId, index);
        setState(() {
          timeSlots.removeAt(index);
        });
      } catch (e) {
        logger.e('Error deleting time slot: $e');
      }
    });
  }

  // Toggle allowed status
  void _toggleAllowedStatus(int index) async {
    bool isAllowed = timeSlots[index]['is_allowed'] == 'true';

    if (isAllowed) {
      showToggleConfirmationPrompt(context, () async {
        await TimeService().toggleAllowedStatus(context, widget.childId, index, false);
        setState(() {
          timeSlots[index]['is_allowed'] = 'false';
        });
      });
    } else {
      // Automatically turn on the schedule without notification
      await TimeService().toggleAllowedStatus(context, widget.childId, index, true);
      setState(() {
        timeSlots[index]['is_allowed'] = 'true';
      });
    }
  }

  // Edit an existing time slot using TimeService
  Future<void> _editTimeSlot(int index) async {
    final startTime = TimeOfDay(
      hour: int.parse(timeSlots[index]['start_time']!.split(':')[0]),
      minute: int.parse(timeSlots[index]['start_time']!.split(':')[1]),
    );

    final endTime = TimeOfDay(
      hour: int.parse(timeSlots[index]['end_time']!.split(':')[0]),
      minute: int.parse(timeSlots[index]['end_time']!.split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTimePromptDialog(
          initialStartTime: startTime,
          initialEndTime: endTime,
          childId: widget.childId,
          onSave: (newStartTime, newEndTime) async {
            if (newStartTime != null && newEndTime != null) {
              try {
                await TimeService().updateTimeSlot(widget.childId, index, newStartTime, newEndTime);
                _fetchTimeSlots(); // Refresh after editing
              } catch (e) {
                logger.e('Error updating time slot: $e');
              }
            }
          },
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
  final TextStyle fontStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 18, // Larger font size
  );

  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: appBarColor,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: const Center(
            child: Text(
              'Set Daily Screen Time Schedule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = timeSlots[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.8, // Reduce the size of the toggle switch (0.8 makes it 80% of its original size)
                      child: Switch(
                        value: timeSlot['is_allowed'] == 'true',
                        onChanged: (value) {
                          _toggleAllowedStatus(index); // Toggle the allowed status
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[400],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        '${_formatTime(timeSlot['start_time']!)} - ${_formatTime(timeSlot['end_time']!)}',
                        style: fontStyle,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: appBarColor, size: 24),
                      onPressed: () {
                        _editTimeSlot(index); // Edit time slot on button click
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: appBarColor, size: 24),
                      onPressed: () {
                        _deleteTimeSlot(index); // Delete time slot on button click
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ScreenTimeScheduleDialog(
                    schedules: timeSlots.map((slot) {
                      return {
                        'start_time': TimeOfDay(
                          hour: int.parse(slot['start_time']!.split(':')[0]),
                          minute: int.parse(slot['start_time']!.split(':')[1]),
                        ),
                        'end_time': TimeOfDay(
                          hour: int.parse(slot['end_time']!.split(':')[0]),
                          minute: int.parse(slot['end_time']!.split(':')[1]),
                        ),
                      };
                    }).toList(),
                    childId: widget.childId,
                    onAddSchedule: _onAddSchedule,
                    onEditSchedule: (int index, TimeOfDay? startTime, TimeOfDay? endTime) {
                      // Handle edit schedule
                    },
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appBarColor,
            ),
            child: const Icon(Icons.add),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Total Set Schedules: ${timeSlots.length}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appBarColor),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

}
*/
/*import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import '../services/time_service.dart';
import 'time_schedule_dialog.dart';
import '../design/edit_time_prompt.dart'; // Import for editing time dialog
import '../design/notification_prompts.dart'; // Import for prompts

final Logger logger = Logger();

class TimeManagement extends StatefulWidget {
  final String childId;

  const TimeManagement({super.key, required this.childId});

  @override
  TimeManagementState createState() => TimeManagementState();
}

class TimeManagementState extends State<TimeManagement> {
  List<Map<String, String>> timeSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots(); // Fetch the initial time slots when the screen loads
  }

  @override
  void didUpdateWidget(covariant TimeManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _fetchTimeSlots(); // Fetch new time slots if the childId changes
    }
  }

  // Fetch time slots from the backend for the selected child
  // Fetch time slots from the backend for the selected child
Future<void> _fetchTimeSlots() async {
  try {
    // Clear the current time slots before fetching new ones
    setState(() {
      timeSlots.clear();
    });

    List<Map<String, dynamic>> fetchedTimeSlots = await TimeService().fetchTimeSlots(widget.childId);

    setState(() {
      timeSlots = fetchedTimeSlots.map((timeSlot) {
        return {
          'start_time': timeSlot['start_time'].toString(),
          'end_time': timeSlot['end_time'].toString(),
          'is_allowed': timeSlot['is_allowed'].toString(),
        };
      }).toList();
    });
  } catch (e) {
    logger.e('Error fetching time slots: $e');
  }
}



  // Callback to handle adding a new schedule
  void _onAddSchedule(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime != null && endTime != null) {
      setState(() {
        timeSlots.add({
          'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          'is_allowed': 'true',
        });
      });
    }
  }
  // Convert 24-hour time format to 12-hour with AM/PM
  String _formatTime(String time) {
    DateTime dateTime = DateFormat.Hm().parse(time); // Parse the time string in 24-hour format
    return DateFormat.jm().format(dateTime); // Convert to 12-hour format with AM/PM
  }

  // Delete a time slot with confirmation prompt
  void _deleteTimeSlot(int index) async {
    showDeleteConfirmationPrompt(context, () async {
      try {
        await TimeService().deleteTimeSlot(widget.childId, index);
        setState(() {
          timeSlots.removeAt(index);
        });
      } catch (e) {
        logger.e('Error deleting time slot: $e');
      }
    });
  }

  // Toggle allowed status
  void _toggleAllowedStatus(int index) async {
    bool isAllowed = timeSlots[index]['is_allowed'] == 'true';

    if (isAllowed) {
      showToggleConfirmationPrompt(context, () async {
        await TimeService().toggleAllowedStatus(context, widget.childId, index, false);
        setState(() {
          timeSlots[index]['is_allowed'] = 'false';
        });
      });
    } else {
      // Automatically turn on the schedule without notification
      await TimeService().toggleAllowedStatus(context, widget.childId, index, true);
      setState(() {
        timeSlots[index]['is_allowed'] = 'true';
      });
    }
  }

  // Edit an existing time slot using TimeService
  Future<void> _editTimeSlot(int index) async {
    final startTime = TimeOfDay(
      hour: int.parse(timeSlots[index]['start_time']!.split(':')[0]),
      minute: int.parse(timeSlots[index]['start_time']!.split(':')[1]),
    );

    final endTime = TimeOfDay(
      hour: int.parse(timeSlots[index]['end_time']!.split(':')[0]),
      minute: int.parse(timeSlots[index]['end_time']!.split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTimePromptDialog(
          initialStartTime: startTime,
          initialEndTime: endTime,
          childId: widget.childId,
          onSave: (newStartTime, newEndTime) async {
            if (newStartTime != null && newEndTime != null) {
              try {
                await TimeService().updateTimeSlot(widget.childId, index, newStartTime, newEndTime);
                _fetchTimeSlots(); // Refresh after editing
              } catch (e) {
                logger.e('Error updating time slot: $e');
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle fontStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 18, // Larger font size
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: appBarColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Center(
              child: Text(
                'Set Daily Screen Time Schedule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  child: Row(
                    children: [
                      Switch(
                        value: timeSlot['is_allowed'] == 'true',
                        onChanged: (value) {
                          _toggleAllowedStatus(index); // Toggle the allowed status
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[400],
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          '${_formatTime(timeSlot['start_time']!)} - ${_formatTime(timeSlot['end_time']!)}',
                          style: fontStyle,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: appBarColor, size: 24),
                        onPressed: () {
                          _editTimeSlot(index); // Edit time slot on button click
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: appBarColor, size: 24),
                        onPressed: () {
                          _deleteTimeSlot(index); // Delete time slot on button click
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ScreenTimeScheduleDialog(
                      schedules: timeSlots.map((slot) {
                        return {
                          'start_time': TimeOfDay(
                            hour: int.parse(slot['start_time']!.split(':')[0]),
                            minute: int.parse(slot['start_time']!.split(':')[1]),
                          ),
                          'end_time': TimeOfDay(
                            hour: int.parse(slot['end_time']!.split(':')[0]),
                            minute: int.parse(slot['end_time']!.split(':')[1]),
                          ),
                        };
                      }).toList(),
                      childId: widget.childId,
                      onAddSchedule: _onAddSchedule,
                      onEditSchedule: (int index, TimeOfDay? startTime, TimeOfDay? endTime) {
                        // Handle edit schedule
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarColor,
              ),
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'Total Set Schedules: ${timeSlots.length}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appBarColor),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}*/


/*
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import '../services/time_service.dart';
import '../design/notification_prompts.dart';
import '../design/edit_time_prompt.dart'; // Import for the edit time prompt dialog

final Logger logger = Logger();

class TimeManagement extends StatefulWidget {
  final String childId;

  const TimeManagement({super.key, required this.childId});

  @override
  TimeManagementState createState() => TimeManagementState();
}

class TimeManagementState extends State<TimeManagement> {
  List<Map<String, String>> timeSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots(); // Fetch the initial time slots when the screen loads
  }

  @override
  void didUpdateWidget(covariant TimeManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _fetchTimeSlots(); // Fetch new time slots if the childId changes
    }
  }

  // Fetch time slots from the backend for the selected child
  Future<void> _fetchTimeSlots() async {
    try {
      List<Map<String, dynamic>> fetchedTimeSlots = await TimeService().fetchTimeSlots(widget.childId);

      setState(() {
        timeSlots = fetchedTimeSlots.map((timeSlot) {
          return {
            'start_time': timeSlot['start_time'].toString(),
            'end_time': timeSlot['end_time'].toString(),
            'is_allowed': timeSlot['is_allowed'].toString(),
          };
        }).toList();
      });
    } catch (e) {
      logger.e('Error fetching time slots: $e');
    }
  }

  // Convert 24-hour time format to 12-hour with AM/PM
  String _formatTime(String time) {
    DateTime dateTime = DateFormat.Hm().parse(time); // Parse the time string in 24-hour format
    return DateFormat.jm().format(dateTime); // Convert to 12-hour format with AM/PM
  }

  // Edit an existing time slot
  Future<void> _editTimeSlot(int index) async {
    final timeSlot = timeSlots[index];

    // Convert string time to TimeOfDay for editing
    final TimeOfDay initialStartTime = TimeOfDay(
      hour: int.parse(timeSlot['start_time']!.split(':')[0]),
      minute: int.parse(timeSlot['start_time']!.split(':')[1]),
    );
    final TimeOfDay initialEndTime = TimeOfDay(
      hour: int.parse(timeSlot['end_time']!.split(':')[0]),
      minute: int.parse(timeSlot['end_time']!.split(':')[1]),
    );

    // Navigate to the edit prompt
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTimePromptDialog(
          initialStartTime: initialStartTime,
          initialEndTime: initialEndTime,
          childId: widget.childId,
          onSave: (startTime, endTime) async {
            if (startTime != null && endTime != null) {
              // Update the selected time slot
              timeSlots[index] = {
                'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                'is_allowed': timeSlot['is_allowed']!, // Preserve the current is_allowed status
              };

              // Save the updated time slot to the backend
              await TimeService().saveTimeManagement(widget.childId, timeSlots);
              _fetchTimeSlots(); // Refresh the time slots after saving
            }
          },
        );
      },
    );
  }

  // Toggle the allowed status for a time slot
  Future<void> _toggleAllowedStatus(int index) async {
    final timeSlot = timeSlots[index];
    bool isAllowed = timeSlot['is_allowed'] == 'true';

    try {
      // Call the backend service to update the `is_allowed` status
      await TimeService().toggleAllowedStatus(context, widget.childId, index, !isAllowed);

      setState(() {
        timeSlots[index]['is_allowed'] = (!isAllowed).toString(); // Update the local state
      });
    } catch (e) {
      logger.e('Error toggling allowed status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle fontStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 18, // Larger font size
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: appBarColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Center(
              child: Text(
                'Set Daily Screen Time Schedule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  child: Row(
                    children: [
                      // Toggle Switch for is_allowed status
                      Switch(
                        value: timeSlot['is_allowed'] == 'true',
                        onChanged: (value) => _toggleAllowedStatus(index),
                        activeColor: Colors.white, // Thumb color when active
                        activeTrackColor: Colors.green, // Track color when active
                        inactiveThumbColor: Colors.white, // Thumb color when inactive
                        inactiveTrackColor: Colors.grey[400], 
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          '${_formatTime(timeSlot['start_time']!)} - ${_formatTime(timeSlot['end_time']!)}',
                          style: fontStyle,
                        ),
                      ),
                      // Edit and delete icons close to the edge of the screen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: appBarColor, size: 24),
                            onPressed: () => _editTimeSlot(index), // Edit time slot on icon click
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: appBarColor, size: 24),
                            onPressed: () => _deleteTimeSlot(index), // Delete time slot on icon click
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _addNewTimeSlot, // Add new time slot
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarColor,
              ),
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'Total Set Schedules: ${timeSlots.length}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appBarColor),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Delete a time slot with confirmation prompt
  void _deleteTimeSlot(int index) async {
    showDeleteConfirmationPrompt(context, () async {
      try {
        await TimeService().deleteTimeSlot(widget.childId, index);
        setState(() {
          timeSlots.removeAt(index);
        });
      } catch (e) {
        logger.e('Error deleting time slot: $e');
      }
    });
  }

  // Add a new time slot
  Future<void> _addNewTimeSlot() async {
    TimeService().addNewTimeSlot(
      context,
      widget.childId,
      timeSlots,
    );
    _fetchTimeSlots(); // Refresh the schedule after adding a new one
  }
}
*/