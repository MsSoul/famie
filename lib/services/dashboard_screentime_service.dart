//filename: services/dashboard_screentime_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'config.dart';  // Import your config file for baseUrl

class DashboardScreenTimeService {
  final Logger logger = Logger();  // Initialize Logger
  WebSocketChannel? _channel;  // WebSocket channel for real-time updates
  Function(Map<String, dynamic>)? onTimeScheduleUpdate; // Callback for time schedule updates
  Function(Map<String, dynamic>)? onRemainingTimeUpdate; // Callback for remaining time updates

  // Open a WebSocket connection
  void openWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${Config.baseUrl}'),  // Replace with your actual WebSocket URL
    );
    logger.i('WebSocket connected to ${Config.baseUrl}');

    // Listen for messages from the WebSocket
    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'time_schedule_update' && onTimeScheduleUpdate != null) {
        logger.i('Received time schedule update: ${data['data']}');
        onTimeScheduleUpdate!(data['data']);
      } else if (data['type'] == 'remaining_time_update' && onRemainingTimeUpdate != null) {
        logger.i('Received remaining time update: ${data['data']}');
        onRemainingTimeUpdate!(data['data']);
      }
    }, onError: (error) {
      logger.e('WebSocket error: $error');
    });
  }

  // Close the WebSocket connection
  void closeWebSocket() {
    _channel?.sink.close(status.goingAway);
    logger.i('WebSocket connection closed');
  }

  // Fetch time schedule (initial load)
  Future<Map<String, dynamic>?> fetchTimeSchedule(String childId) async {
    final String url = '${Config.baseUrl}/api/screen-time/get-time-schedule/$childId';
    logger.i('Sending request to $url with childId: $childId');  // Log childId and URL

    try {
      final response = await http.get(Uri.parse(url));

      logger.i('Response from $url: ${response.statusCode}'); // Log the status code
      if (response.body.isNotEmpty) {
        logger.i('Response body: ${response.body}');  // Log the response body
      } else {
        logger.w('Empty response body from $url');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> timeSchedule = json.decode(response.body);
        logger.i('Successfully fetched time schedule: $timeSchedule');
        return timeSchedule;
      } else if (response.statusCode == 404) {
        logger.w('No time schedule found for childId: $childId');
        return null;
      } else {
        logger.e('Unexpected error fetching time schedule: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Exception occurred while fetching time schedule: $e');  // Log exceptions
      return null;
    }
  }

  // Fetch remaining time (initial load)
  Future<Map<String, dynamic>?> fetchRemainingTime(String childId) async {
    final String url = '${Config.baseUrl}/api/screen-time/get-remaining-time/$childId';
    logger.i('Sending request to $url with childId: $childId');  // Log childId and URL

    try {
      final response = await http.get(Uri.parse(url));

      logger.i('Response from $url: ${response.statusCode}'); // Log the status code
      if (response.body.isNotEmpty) {
        logger.i('Response body: ${response.body}');  // Log the response body
      } else {
        logger.w('Empty response body from $url');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> remainingTime = json.decode(response.body);
        logger.i('Successfully fetched remaining time: $remainingTime');
        return remainingTime;
      } else if (response.statusCode == 404) {
        logger.w('No remaining time found for childId: $childId');
        return null;
      } else {
        logger.e('Unexpected error fetching remaining time: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Exception occurred while fetching remaining time: $e');  // Log exceptions
      return null;
    }
  }
}


/*import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'config.dart';  // Import your config file for baseUrl

class DashboardScreenTimeService {
  final Logger logger = Logger();  // Initialize Logger

  // Fetch time schedule (time_slots from time_management)
  Future<Map<String, dynamic>?> fetchTimeSchedule(String childId) async {
    final String url = '${Config.baseUrl}/api/screen-time/get-time-schedule/$childId';
    logger.i('Sending request to $url with childId: $childId');

    try {
      final response = await http.get(Uri.parse(url));
      logger.i('Response from $url: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> timeSchedule = json.decode(response.body);
        logger.i('Successfully fetched time schedule: $timeSchedule');
        return timeSchedule;
      } else {
        logger.e('Failed to fetch time schedule: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching time schedule: $e');
      return null;
    }
  }

  // Fetch remaining time (time_slots from remaining_time)
  Future<Map<String, dynamic>?> fetchRemainingTime(String childId) async {
    final String url = '${Config.baseUrl}/api/screen-time/get-remaining-time/$childId';
    logger.i('Sending request to $url with childId: $childId');

    try {
      final response = await http.get(Uri.parse(url));
      logger.i('Response from $url: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> remainingTime = json.decode(response.body);
        logger.i('Successfully fetched remaining time: $remainingTime');
        return remainingTime;
      } else {
        logger.e('Failed to fetch remaining time: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching remaining time: $e');
      return null;
    }
  }
}
*/