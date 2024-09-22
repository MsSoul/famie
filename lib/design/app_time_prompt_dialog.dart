//filename:design/app_time_prompt_dialog.dart(displaying of app time schedule using the clock icon)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_time_service.dart';
import '../design/app_toggle_prompt.dart'; // Import AppTogglePrompt

class AppTimePromptDialog extends StatefulWidget {
  final String appId;
  final String childId;
  final String appName;

  const AppTimePromptDialog({
    super.key,
    required this.appId,
    required this.childId,
    required this.appName,
  });

  @override
  AppTimePromptDialogState createState() => AppTimePromptDialogState();
}

class AppTimePromptDialogState extends State<AppTimePromptDialog> {
  List<Map<String, String>> timeSlots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppTimeSlots();
  }

  Future<void> _fetchAppTimeSlots() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> fetchedTimeSlots = await AppTimeService().fetchAppTimeSlots(widget.appName, widget.childId);

      if (mounted) {
        setState(() {
          timeSlots = fetchedTimeSlots.map((timeSlot) {
            return {
              'start_time': timeSlot['start_time'].toString(),
              'end_time': timeSlot['end_time'].toString(),
            };
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching time slots: $e')));
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Add a new time slot using AppTogglePrompt
  Future<void> _addNewTimeSlot() async {
    await showDialog(
      context: context,
      builder: (context) => AppTogglePrompt(
        appId: widget.appId,
        childId: widget.childId,
        appName: widget.appName,
      ),
    );
    // Refresh time slots after adding a new one
    if (mounted) {
      _fetchAppTimeSlots();
    }
  }

  Future<void> _deleteTimeSlot(int index) async {
    await AppTimeService().deleteTimeSlot(widget.appName, widget.childId, index);
    if (mounted) {
      setState(() {
        timeSlots.removeAt(index);
      });
    }
  }

  String _formatTime(String time) {
    DateTime dateTime = DateFormat.Hm().parse(time);
    return DateFormat.jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final Color actionColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[400]!;
    final TextStyle fontStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'App Time Schedule for ${widget.appName}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : timeSlots.isEmpty
                    ? const Center(child: Text("No time slots available."))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          final timeSlot = timeSlots[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),  // Tighter padding
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatTime(timeSlot['start_time']!)} - ${_formatTime(timeSlot['end_time']!)}',
                                  style: fontStyle,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: actionColor),  // Use actionColor for consistency
                                  onPressed: () => _deleteTimeSlot(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 10),
            Center(
  child: ElevatedButton(
    onPressed: _addNewTimeSlot,  // Call _addNewTimeSlot when pressed
    style: ElevatedButton.styleFrom(
      backgroundColor: actionColor,  // Use the same actionColor for the add button
      shape: RoundedRectangleBorder(  // Change to RoundedRectangleBorder
        borderRadius: BorderRadius.circular(10),  // Set border radius to 10
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),  // Adjust padding for the rectangle shape
    ),
    child: const Icon(Icons.add),
  ),
),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Total Set Schedules: ${timeSlots.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: actionColor),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_time_service.dart';
import '../design/app_toggle_prompt.dart';

class AppTimePromptDialog extends StatefulWidget {
  final String appId;
  final String childId;
  final String appName;

  const AppTimePromptDialog({
    super.key,
    required this.appId,
    required this.childId,
    required this.appName,
  });

  @override
  AppTimePromptDialogState createState() => AppTimePromptDialogState();
}

class AppTimePromptDialogState extends State<AppTimePromptDialog> {
  List<Map<String, String>> timeSlots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppTimeSlots();
  }

  Future<void> _fetchAppTimeSlots() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> fetchedTimeSlots = await AppTimeService().fetchAppTimeSlots(widget.appName, widget.childId);

      if (mounted) {
        setState(() {
          timeSlots = fetchedTimeSlots.map((timeSlot) {
            return {
              'start_time': timeSlot['start_time'].toString(),
              'end_time': timeSlot['end_time'].toString(),
            };
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching time slots: $e')));
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addNewTimeSlot() async {
    await showDialog(
      context: context,
      builder: (context) => AppTogglePrompt(
        appId: widget.appId,
        childId: widget.childId,
        appName: widget.appName,
      ),
    );
    if (mounted) {
      _fetchAppTimeSlots();
    }
  }

  Future<void> _editTimeSlot(int index) async {
    await AppTimeService().editTimeSlot(context, widget.appName, widget.childId, timeSlots, index);
    if (mounted) {
      _fetchAppTimeSlots();
    }
  }

  Future<void> _deleteTimeSlot(int index) async {
    await AppTimeService().deleteTimeSlot(widget.appName, widget.childId, index);
    if (mounted) {
      setState(() {
        timeSlots.removeAt(index);
      });
    }
  }

  String _formatTime(String time) {
    DateTime dateTime = DateFormat.Hm().parse(time);
    return DateFormat.jm().format(dateTime);
  }

    @override
  Widget build(BuildContext context) {
    final Color actionColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[400]!;
    final TextStyle fontStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'App Time Schedule for ${widget.appName}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : timeSlots.isEmpty
                    ? const Center(child: Text("No time slots available."))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          final timeSlot = timeSlots[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),  // Reduced padding for closer alignment
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatTime(timeSlot['start_time']!)} - ${_formatTime(timeSlot['end_time']!)}',
                                  style: fontStyle,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: actionColor),  // Use actionColor for consistency
                                      onPressed: () => _editTimeSlot(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: actionColor),  // Use actionColor for consistency
                                      onPressed: () => _deleteTimeSlot(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _addNewTimeSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,  // Use the same actionColor for the add button
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.add),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Total Set Schedules: ${timeSlots.length}',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: actionColor),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}*/