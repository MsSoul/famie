// filename: ../dashboard/dashboard_screen_time.dart
import 'package:flutter/material.dart';
import '../services/dashboard_screentime_service.dart';
import 'package:intl/intl.dart';

class DashboardScreenTime extends StatefulWidget {
  final String childId;

  const DashboardScreenTime({super.key, required this.childId});

  @override
  DashboardScreenTimeState createState() => DashboardScreenTimeState();
}

class DashboardScreenTimeState extends State<DashboardScreenTime> {
  final DashboardScreenTimeService _service = DashboardScreenTimeService();
  List<dynamic> timeSchedule = []; // Holds time slots
  List<dynamic> remainingTime = []; // Holds remaining time data
  bool isLoading = true; // Track loading state
  bool hasError = false; // Track error state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DashboardScreenTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      timeSchedule = []; // Clear any existing data
      remainingTime = [];
    });

    try {
      final schedule = await _service.fetchTimeSchedule(widget.childId);
      final remaining = await _service.fetchRemainingTime(widget.childId);

      setState(() {
        timeSchedule = schedule?['time_slots'] ?? [];
        remainingTime = remaining?['remaining_time'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      debugPrint("Error loading screen time data: $e");
    }
  }

  String formatTime(String time24) {
    final dateTime = DateFormat("HH:mm").parse(time24);
    return DateFormat("hh:mm a").format(dateTime);
  }

  String formatRemainingTime(int remainingSeconds) {
    final int hours = remainingSeconds ~/ 3600;
    final int minutes = (remainingSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screen Time Schedule',
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
                          : (timeSchedule.isEmpty && remainingTime.isEmpty)
                              ? const Center(child: Text("No Schedule Available"))
                              : SingleChildScrollView(child: _buildTimeData()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScheduleSection("Allowed Schedules", timeSchedule),
        const SizedBox(height: 10),
        _buildScheduleSection(
          "Remaining Schedules",
          remainingTime.where((slot) => slot['remaining_time'] != 0).toList(),
        ),
        const SizedBox(height: 10),
        _buildAllowedScheduleSection("Allowed Time on each Schedule", timeSchedule),
      ],
    );
  }

  Widget _buildScheduleSection(String title, List<dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(8.0),
          child: data.isEmpty
              ? const Text("No Remaining Schedule Available")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final slot = data[index];
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
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAllowedScheduleSection(String title, List<dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(8.0),
          child: data.isEmpty
              ? const Text("No Allowed Schedule available")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final slot = data[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${formatTime(slot['start_time'])} - ${formatTime(slot['end_time'])}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Allowed Time: ${slot['allowed_time'] != null ? formatRemainingTime(slot['allowed_time']) : 'N/A'}", // Display allowed time
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
