// filename: design/schedule_prompt.dart
// filename: design/schedule_prompt.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart'; // Import logger
import '../services/dashboard_screentime_service.dart';

class SchedulePrompt extends StatefulWidget {
  final String childId;
  final VoidCallback onClose; // Callback for close button

  const SchedulePrompt({super.key, required this.childId, required this.onClose});

  @override
  SchedulePromptState createState() => SchedulePromptState();
}

class SchedulePromptState extends State<SchedulePrompt> {
  final DashboardScreenTimeService service = DashboardScreenTimeService();
  final Logger logger = Logger(); // Create a logger instance
  List<dynamic>? timeSlots; // Holds time slots
  bool isLoading = true; // Track loading state
  String? errorMessage; // Track error message

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Reset error message
    });

    try {
      final schedule = await service.fetchTimeSchedule(widget.childId);

      // Log the fetched schedule to see its structure
      logger.i("Fetched schedule: $schedule");

      setState(() {
        if (schedule != null && schedule.containsKey('time_slots')) {
          timeSlots = schedule['time_slots'] as List<dynamic>; // Get all time slots
        } else {
          timeSlots = []; // No time slots available
        }
        isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading data: $e'); // Log the error for debugging
      setState(() {
        errorMessage = 'Failed to load data. Please try again later.';
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Rounded corners for the dialog
      ),
      child: Container(
        // Remove fixed height and allow content to dictate size
        padding: const EdgeInsets.all(12.0), // Inner padding
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).appBarTheme.backgroundColor!, // Border color matches app bar
            width: 2.0, // Border width
          ),
          borderRadius: BorderRadius.circular(15.0), // Match the dialog's rounded corners
        ),
        child: SingleChildScrollView( // Allow scrolling for long content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title centered with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Schedules',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: widget.onClose, // Trigger the close callback
                  ),
                ],
              ),
              const SizedBox(height: 8), // Space between title and content
              // Schedules container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the schedules
                  border: Border.all(
                    color: Theme.of(context).appBarTheme.backgroundColor!, // Border color around the schedules
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners for the box
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Inner padding for the schedules
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(child: Text(errorMessage!))
                          : (timeSlots == null || timeSlots!.isEmpty)
                              ? const Center(child: Text("No schedules available"))
                              : ListView.builder(
                                  shrinkWrap: true, // Allow the ListView to take only the space it needs
                                  physics: const NeverScrollableScrollPhysics(), // Prevent ListView from scrolling
                                  itemCount: timeSlots!.length,
                                  itemBuilder: (context, index) {
                                    final slot = timeSlots![index];
                                    return buildScheduleItem(slot);
                                  },
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScheduleItem(dynamic slot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), // Reduced vertical padding
      child: Text(
        "${formatTime(slot['start_time'])} - ${formatTime(slot['end_time'])}",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}


/*
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
*/