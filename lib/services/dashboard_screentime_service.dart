// filename: services/dashboard_screentime_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'config.dart';  

class DashboardScreenTimeService {
  final Logger logger = Logger();  

  // Fetch time schedule (initial load)
  Future<Map<String, dynamic>?> fetchTimeSchedule(String childId) async {
    final String url = '${Config.baseUrl}/api/dashboard_screen_time/get-time-schedule/$childId';
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
    final String url = '${Config.baseUrl}/api/dashboard_screen_time/get-remaining-time/$childId';
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

  // Fetch allowed time (initial load)
  Future<Map<String, dynamic>?> fetchAllowedTime(String childId) async {
    final String url = '${Config.baseUrl}/api/dashboard_screen_time/get-allowed-time/$childId';
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
        final Map<String, dynamic> allowedTime = json.decode(response.body);
        logger.i('Successfully fetched allowed time: $allowedTime');
        return allowedTime;
      } else if (response.statusCode == 404) {
        logger.w('No allowed time found for childId: $childId');
        return null;
      } else {
        logger.e('Unexpected error fetching allowed time: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Exception occurred while fetching allowed time: $e');  // Log exceptions
      return null;
    }
  }
}
