//filename:dashboard/dashboard_screen_time.dart
// filename: dashboard/dashboard_screen_time.dart
import 'package:flutter/material.dart';
import '../services/dashboard_screentime_service.dart';
import 'package:intl/intl.dart'; // For time formatting

class DashboardScreenTime extends StatefulWidget {
  final String childId;

  const DashboardScreenTime({super.key, required this.childId});

  @override
  DashboardScreenTimeState createState() => DashboardScreenTimeState();
}

class DashboardScreenTimeState extends State<DashboardScreenTime> {
  final DashboardScreenTimeService _service = DashboardScreenTimeService();
  List<dynamic>? timeSchedule; // Holds time slots
  List<dynamic>? remainingTime; // Holds remaining time data
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
    });

    try {
      final schedule = await _service.fetchTimeSchedule(widget.childId);
      final remaining = await _service.fetchRemainingTime(widget.childId);

      setState(() {
        timeSchedule = schedule?['time_slots'] as List<dynamic>?; // Cast to List<dynamic>
        remainingTime = remaining?['time_slots'] as List<dynamic>?; // Cast to List<dynamic>
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

  String formatRemainingTime(int remainingSeconds) {
    final int hours = remainingSeconds ~/ 3600;
    final int minutes = (remainingSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
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
                          : (timeSchedule == null || remainingTime == null)
                              ? const Center(child: Text("No data available"))
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
        _buildScheduleSection("Allowed Schedules", timeSchedule ?? []),
        const SizedBox(height: 10),
        _buildScheduleSection(
            "Remaining Schedules",
            remainingTime?.where((slot) => slot['remaining_time'] != 0).toList() ?? []),
        const SizedBox(height: 10),
        _buildRemainingTimeSection("Remaining Time on each Schedule", remainingTime ?? []),
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
            color: Colors.white, // White background for schedule fields
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

  Widget _buildRemainingTimeSection(String title, List<dynamic> data) {
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
            color: Colors.white, // White background for remaining time fields
          ),
          padding: const EdgeInsets.all(8.0),
          child: data.isEmpty
              ? const Text("No Remaining Schedule available")
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
                            "Remaining Time: ${slot['remaining_time'] != null ? formatRemainingTime(slot['remaining_time']) : 'N/A'}",
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

/*
import 'package:flutter/material.dart';
import '../services/dashboard_screentime_service.dart';
import 'package:intl/intl.dart'; // For time formatting

class DashboardScreenTime extends StatefulWidget {
  final String childId;

  const DashboardScreenTime({super.key, required this.childId});

  @override
  DashboardScreenTimeState createState() => DashboardScreenTimeState();
}

class DashboardScreenTimeState extends State<DashboardScreenTime> {
  final DashboardScreenTimeService _service = DashboardScreenTimeService();
  List<dynamic>? timeSchedule; // Holds time slots
  List<dynamic>? remainingTime; // Holds remaining time data
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
    });

    try {
      final schedule = await _service.fetchTimeSchedule(widget.childId);
      final remaining = await _service.fetchRemainingTime(widget.childId);

      setState(() {
        timeSchedule = schedule?['time_slots'] as List<dynamic>?; // Cast to List<dynamic>
        remainingTime = remaining?['time_slots'] as List<dynamic>?; // Cast to List<dynamic>
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

  String formatRemainingTime(int remainingSeconds) {
    final int hours = remainingSeconds ~/ 3600;
    final int minutes = (remainingSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1.2, // Make screen time section larger
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0), // Add a little padding above the text
              child: Text(
                'Screen Time Schedule',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text("Failed to load data"))
                      : (timeSchedule == null || remainingTime == null)
                          ? const Center(child: Text("No data available"))
                          : SingleChildScrollView(child: _buildTimeData()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScheduleSection("Allowed Schedules", timeSchedule ?? []),
        const SizedBox(height: 10),
        _buildScheduleSection(
            "Remaining Schedules",
            remainingTime?.where((slot) => slot['remaining_time'] != 0).toList() ?? []),
        const SizedBox(height: 10),
        _buildRemainingTimeSection("Remaining Time on each Schedule", remainingTime ?? []),
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

  Widget _buildRemainingTimeSection(String title, List<dynamic> data) {
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
          ),
          padding: const EdgeInsets.all(8.0),
          child: data.isEmpty
              ? const Text("No Remaining Schedule available")
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
                            "Remaining Time: ${slot['remaining_time'] != null ? formatRemainingTime(slot['remaining_time']) : 'N/A'}",
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
*/

/*import 'package:flutter/material.dart';
import '../services/dashboard_screentime_service.dart';
import 'package:intl/intl.dart'; // For time formatting

class DashboardScreenTime extends StatefulWidget {
  final String childId;

  const DashboardScreenTime({super.key, required this.childId});

  @override
  DashboardScreenTimeState createState() => DashboardScreenTimeState();
}

class DashboardScreenTimeState extends State<DashboardScreenTime> {
  final DashboardScreenTimeService _service = DashboardScreenTimeService();
  List<dynamic>? timeSchedule; // Holds time slots
  List<dynamic>? remainingTime; // Holds remaining time data
  bool isLoading = true; // Track loading state
  bool hasError = false; // Track error state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // This method is called whenever the widget’s configuration changes.
  @override
  void didUpdateWidget(covariant DashboardScreenTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      // Trigger data reload when childId changes
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final schedule = await _service.fetchTimeSchedule(widget.childId);
      final remaining = await _service.fetchRemainingTime(widget.childId);

      setState(() {
        timeSchedule = schedule?['time_slots'] as List<dynamic>?; // Cast to List<dynamic>
        remainingTime = remaining?['time_slots'] as List<dynamic>?; // Cast to List<dynamic>
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
    // Convert time from 24-hour format to 12-hour format
    final dateTime = DateFormat("HH:mm").parse(time24);
    return DateFormat("hh:mm a").format(dateTime);
  }

  String formatRemainingTime(int remainingSeconds) {
    // Convert remaining time from seconds to hours and minutes
    final int hours = remainingSeconds ~/ 3600;
    final int minutes = (remainingSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title remains fixed
        Text(
          'Screen Time Schedule',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).appBarTheme.backgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 10),
        // Scrollable content starts here
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading spinner
              : hasError
                  ? const Center(child: Text("Failed to load data")) // Handle error
                  : (timeSchedule == null || remainingTime == null)
                      ? const Center(child: Text("No data available")) // Handle no data
                      : SingleChildScrollView(
                          child: _buildTimeData(), // Scrollable data
                        ),
        ),
      ],
    ),
  );
}


  Widget _buildTimeData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScheduleSection("Allowed Schedules", timeSchedule ?? []),
        const SizedBox(height: 10),
        _buildScheduleSection(
            "Remaining Schedules",
            remainingTime?.where((slot) => slot['remaining_time'] != 0).toList() ?? []),
        const SizedBox(height: 10),
        _buildRemainingTimeSection("Remaining Time on each Schedule", remainingTime ?? []),
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
        // Wrap the schedule section in a container with a border
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green, // Set border color
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0), // Set border radius
          ),
          padding: const EdgeInsets.all(8.0), // Padding inside the border
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

  Widget _buildRemainingTimeSection(String title, List<dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        // Add a container with a border for the remaining time section
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.green, // Set border color
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0), // Set border radius
          ),
          padding: const EdgeInsets.all(8.0),
          child: data.isEmpty
              ? const Text("No Remaining Schedule available")
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
                          // Display formatted remaining time below the schedule
                          Text(
                            "Remaining Time: ${slot['remaining_time'] != null ? formatRemainingTime(slot['remaining_time']) : 'N/A'}",
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
*/