// filename: dashboard/dashboard_app_time.dart
import 'package:flutter/material.dart';
import '../services/dashboard_app_time_service.dart';
import 'package:intl/intl.dart'; // For time formatting

class DashboardAppTime extends StatefulWidget {
  final String childId;

  const DashboardAppTime({super.key, required this.childId});

  @override
  _DashboardAppTimeState createState() => _DashboardAppTimeState();
}

class _DashboardAppTimeState extends State<DashboardAppTime> {
  final DashboardAppTimeService _service = DashboardAppTimeService();
  List<Map<String, dynamic>>? appTimeData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DashboardAppTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      appTimeData = []; // Clear any existing data
    });

    try {
      final appTime = await _service.fetchAppTime(widget.childId);
      setState(() {
        appTimeData = appTime ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      debugPrint("Error loading app time data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
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
                'App Time Schedule',
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
                        ? const Center(child: Text("Failed to load app time data"))
                        : (appTimeData == null || appTimeData!.isEmpty)
                            ? _buildNoDataView()
                            : _buildAppTimeData(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Text(
        "No App Time Schedule",
        style: TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAppTimeData() {
    return ListView.builder(
      itemCount: appTimeData!.length,
      itemBuilder: (context, index) {
        final app = appTimeData![index];
        final timeSlots = app['time_slots'] as List<dynamic>? ?? [];
        return _buildAppTimeCard(app['app_name'], timeSlots);
      },
    );
  }

  Widget _buildAppTimeCard(String? appName, List<dynamic> timeSlots) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appName ?? 'Unknown App',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: timeSlots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_formatTime(slot['start_time'] ?? '')} - ${_formatTime(slot['end_time'] ?? '')}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Allowed Time: ${_formatAllowedTime(slot['allowed_time'] ?? 0)}", // Updated line
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format time to 12-hour format
  String _formatTime(String time24) {
    try {
      final dateTime = DateFormat("HH:mm").parse(time24);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      debugPrint("Error formatting time: $e");
      return "--:--"; // Fallback if parsing fails
    }
  }

  // Helper method to format allowed time
  String _formatAllowedTime(int allowedSeconds) {
    final hours = allowedSeconds ~/ 3600;
    final minutes = (allowedSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }
}
