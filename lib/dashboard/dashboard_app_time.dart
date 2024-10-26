// filename:dashboard/dashboard_app_time.dart
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
    });

    try {
      final appTime = await _service.fetchAppTime(widget.childId);
      setState(() {
        appTimeData = appTime;
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
                        "Remaining Time: ${_formatRemainingTime(slot['remaining_time'] ?? 0)}",
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

  // Helper method to format remaining time
  String _formatRemainingTime(int remainingSeconds) {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }
}


/*
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
    _service.onAppTimeUpdate = _handleAppTimeUpdate;
    _service.onRemainingAppTimeUpdate = _handleRemainingAppTimeUpdate;
    _service.openWebSocket();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DashboardAppTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _service.closeWebSocket();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final appTime = await _service.fetchAppTime(widget.childId);
      setState(() {
        appTimeData = appTime;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void _handleAppTimeUpdate(List<dynamic> updatedData) {
    setState(() {
      appTimeData = updatedData.cast<Map<String, dynamic>>();
    });
  }

  void _handleRemainingAppTimeUpdate(List<dynamic> updatedData) {
    setState(() {
      appTimeData = updatedData.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0), // Remove top padding
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
                        "${_formatTime(slot['start_time'])} - ${_formatTime(slot['end_time'])}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Remaining Time: ${_formatRemainingTime(slot['remaining_time'] ?? 0)}",
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
    final dateTime = DateFormat("HH:mm").parse(time24);
    return DateFormat("hh:mm a").format(dateTime);
  }

  // Helper method to format remaining time
  String _formatRemainingTime(int remainingSeconds) {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }
}
*/

/*working ni wla ray design
import 'package:flutter/material.dart';
import '../services/dashboard_app_time_service.dart';

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
    _service.onAppTimeUpdate = _handleAppTimeUpdate; // Set WebSocket callback
    _service.onRemainingAppTimeUpdate = _handleRemainingAppTimeUpdate; // Set WebSocket callback
    _service.openWebSocket(); // Open WebSocket connection
    _loadData(); // Fetch data from API initially
  }

  @override
  void dispose() {
    _service.closeWebSocket(); // Close WebSocket connection when the widget is disposed
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final appTime = await _service.fetchAppTime(widget.childId);
      setState(() {
        appTimeData = appTime;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Handle WebSocket updates for app time
  void _handleAppTimeUpdate(List<dynamic> updatedData) {
    setState(() {
      appTimeData = updatedData.cast<Map<String, dynamic>>();
    });
  }

  // Handle WebSocket updates for remaining app time
  void _handleRemainingAppTimeUpdate(List<dynamic> updatedData) {
    setState(() {
      appTimeData = updatedData.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError || appTimeData == null) {
      return const Center(child: Text("Failed to load app time data"));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: appTimeData!.map((app) {
            final timeSlots = app['time_slots'] as List<dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app['app_name'], // Display app name
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                ...timeSlots.map((slot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Start: ${slot['start_time']} - End: ${slot['end_time']}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Remaining: ${slot['remaining_time']} seconds", // Display remaining time
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  );
                }).toList(),
                const Divider(), // Divider between app time entries
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
*/