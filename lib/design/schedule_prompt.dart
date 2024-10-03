// filename: design/schedule_prompt.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/dashboard_screentime_service.dart';

class SchedulePrompt extends StatefulWidget {
  final String childId;

  const SchedulePrompt({super.key, required this.childId});

  @override
  _SchedulePromptState createState() => _SchedulePromptState();
}

class _SchedulePromptState extends State<SchedulePrompt> {
  final DashboardScreenTimeService _service = DashboardScreenTimeService();
  List<dynamic>? allowedSchedules; // Holds allowed schedules
  bool isLoading = true; // Track loading state
  bool hasError = false; // Track error state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final schedule = await _service.fetchTimeSchedule(widget.childId);

      setState(() {
        // Filter only the allowed schedules where `is_allowed` is true
        allowedSchedules = (schedule?['time_slots'] as List<dynamic>?)
            ?.where((slot) => slot['is_allowed'] == true)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String formatTime(String time24) {
    final dateTime = DateFormat("HH:mm").parse(time24);
    return DateFormat("hh:mm a").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1.2, // Make screen time section larger
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light gray background color
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allowed Schedules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : hasError
                          ? const Center(child: Text("Failed to load data"))
                          : (allowedSchedules == null || allowedSchedules!.isEmpty)
                              ? const Center(child: Text("No allowed schedules available"))
                              : SingleChildScrollView(child: _buildAllowedSchedules()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllowedSchedules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allowedSchedules!.map((slot) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${formatTime(slot['start_time'])} - ${formatTime(slot['end_time'])}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
