// filename: services/dashboard_app_time_service.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Your configuration file

class DashboardAppTimeService {
  final Logger logger = Logger(); // Initialize Logger

  // Fetch app time data from REST API
  Future<List<Map<String, dynamic>>?> fetchAppTime(String childId) async {
    final String url = '${Config.baseUrl}/api/dashboard_app_time/get-app-time/$childId';
    logger.i('Fetching app time data from $url'); // Info log

    try {
      final response = await http.get(Uri.parse(url));
      logger.i('Response status: ${response.statusCode}'); // Info log
      logger.i('Response body: ${response.body}'); // Log the body of the response

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        logger.i('Fetched app time data: $data'); // Info log
        return data.cast<Map<String, dynamic>>();
      } else {
        // Log the error response body for debugging
        logger.e('Failed to fetch app time data: ${response.statusCode} - ${response.body}'); // Error log
        return null;
      }
    } catch (e) {
      logger.e('Exception while fetching app time data: $e'); // Error log
      return null;
    }
  }

  // Fetch remaining app time data from REST API
  Future<List<Map<String, dynamic>>?> fetchRemainingAppTime(String childId) async {
    final String url = '${Config.baseUrl}/api/dashboard_app_time/get-remaining-app-time/$childId';
    logger.i('Fetching remaining app time data from $url'); // Info log

    try {
      final response = await http.get(Uri.parse(url));
      logger.i('Response status: ${response.statusCode}'); // Info log
      logger.i('Response body: ${response.body}'); // Log the body of the response

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        logger.i('Fetched remaining app time data: $data'); // Info log
        return data.cast<Map<String, dynamic>>();
      } else {
        // Log the error response body for debugging
        logger.e('Failed to fetch remaining app time data: ${response.statusCode} - ${response.body}'); // Error log
        return null;
      }
    } catch (e) {
      logger.e('Exception while fetching remaining app time data: $e'); // Error log
      return null;
    }
  }
}
