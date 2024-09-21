// filename: time_management.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import '../services/time_service.dart';
import '../design/notification_prompts.dart'; // Import for notification prompt

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
    // Fetch the initial child time slots when the screen loads
    _fetchTimeSlots();
  }

  @override
  void didUpdateWidget(covariant TimeManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the childId has changed, if so, fetch new time slots for the new child
    if (oldWidget.childId != widget.childId) {
      _fetchTimeSlots();
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
    TimeService().editTimeSlot(
      context,
      widget.childId,
      timeSlots,
      index,
    );
    _fetchTimeSlots(); // Refresh the schedule after editing
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

  // Convert 24-hour time format to 12-hour with AM/PM
  String _formatTime(String time) {
    DateTime dateTime = DateFormat.Hm().parse(time); // Parse the time string in 24-hour format
    return DateFormat.jm().format(dateTime); // Convert to 12-hour format with AM/PM
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
                      // Moved toggle to the left
                      Expanded(
                        flex: 2,
                        child: Switch(
                          value: timeSlot['is_allowed'] == 'true',
                            activeColor: Colors.white, // Thumb color when active
                            activeTrackColor: Colors.green, // Track color when active
                            inactiveThumbColor: Colors.white, // Thumb color when inactive
                            inactiveTrackColor: Colors.grey[400],// White when OFF
                          onChanged: (value) => _toggleAllowedStatus(index),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          '${_formatTime(timeSlot['start_time']!)} - ${_formatTime(timeSlot['end_time']!)}',
                          style: fontStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end, // Align icons to the end (right)
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: appBarColor, size: 24),
                              onPressed: () => _editTimeSlot(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: appBarColor, size: 24),
                              onPressed: () => _deleteTimeSlot(index),
                            ),
                          ],
                        ),
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
}


/*
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/time_service.dart';
import 'time_schedule_dialog.dart'; 

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
    _fetchTimeSlots(); // Fetch the time slots immediately when the screen initializes
  }

  // Fetch time slots from the backend
  Future<void> _fetchTimeSlots() async {
    try {
      List<Map<String, dynamic>> fetchedTimeSlots = await TimeService().fetchTimeSlots(widget.childId);

      // Convert dynamic values to String for the required List<Map<String, String>> type
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

  // Add new time slot by showing a dialog to select times
  void _addNewTimeSlot() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScreenTimeScheduleDialog(
          schedules: const [],
          childId: widget.childId,
          onAddSchedule: (startTime, endTime) async {
            if (startTime != null && endTime != null) {
              Map<String, String> newTimeSlot = {
                'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                'is_allowed': 'true',
              };
              setState(() {
                timeSlots.add(newTimeSlot);
              });

              // Save the new slot
              try {
                await TimeService().saveTimeManagement(widget.childId, timeSlots);
              } catch (e) {
                logger.e('Error saving new time slot: $e');
              }
            }
          },
          onEditSchedule: (_, __, ___) {}, // Placeholder for editing functionality
        );
      },
    );
  }

  // Delete a time slot
  void _deleteTimeSlot(int index) async {
    try {
      await TimeService().deleteTimeSlot(widget.childId, index);
      setState(() {
        timeSlots.removeAt(index);
      });
    } catch (e) {
      logger.e('Error deleting time slot: $e');
    }
  }

  // Toggle allowed status
  void _toggleAllowedStatus(int index) async {
    setState(() {
      timeSlots[index]['is_allowed'] = timeSlots[index]['is_allowed'] == 'true' ? 'false' : 'true';
    });
    try {
      await TimeService().toggleAllowedStatus(widget.childId, index, timeSlots[index]['is_allowed'] == 'true');
    } catch (e) {
      logger.e('Error toggling allowed status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch app bar color and font style from the theme
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
   final TextStyle fontStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.bold, // Ensure bold text
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Make the header stretch across the screen
        children: [
          // Header with reduced top/bottom space
          Container(
            color: appBarColor,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Reduce padding
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
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0), // Reduce vertical padding
                  child: ListTile(
                    title: Text(
                      '${timeSlot['start_time']} - ${timeSlot['end_time']}',
                      style: fontStyle, // Use the theme's font style
                    ),
                    leading: Switch(
                      value: timeSlot['is_allowed'] == 'true',
                      activeColor: Colors.green, // Make the toggle green when allowed
                      inactiveThumbColor: Colors.white, // White when not allowed
                      onChanged: (value) => _toggleAllowedStatus(index), // Toggle the status
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink toggle size
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: appBarColor, size: 28), // Smaller edit icon
                          onPressed: () {
                            // Handle time slot editing
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ScreenTimeScheduleDialog(
                                  schedules: const [],
                                  childId: widget.childId,
                                  onAddSchedule: (startTime, endTime) {},
                                  onEditSchedule: (index, startTime, endTime) async {
                                    if (startTime != null && endTime != null) {
                                      setState(() {
                                        timeSlots[index] = {
                                          'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                                          'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                                          'is_allowed': timeSlots[index]['is_allowed']!,
                                        };
                                      });
                                      try {
                                        await TimeService().saveTimeManagement(widget.childId, timeSlots);
                                      } catch (e) {
                                        logger.e('Error saving edited time slot: $e');
                                      }
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: appBarColor, size: 24), // Smaller delete icon
                          onPressed: () => _deleteTimeSlot(index), // Delete the time slot
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Add button with smaller margin
          Center(
            child: ElevatedButton(
              onPressed: _addNewTimeSlot, // Opens the dialog to add a new time slot
              style: ElevatedButton.styleFrom(
                backgroundColor: appBarColor, // Use app bar color for "+" button
              ),
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'Total Set Schedules: ${timeSlots.length}', // Display total number of set schedules
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appBarColor),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}*/