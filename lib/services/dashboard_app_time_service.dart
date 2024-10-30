// filename: services/dashboard_app_time_service.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Your configuration file

class DashboardAppTimeService {
  final Logger logger = Logger(); // Initialize Logger

  // Fetch app time data (allowed time) from REST API
  Future<List<Map<String, dynamic>>?> fetchAppTime(String childId) async {
    final String url = '${Config.baseUrl}/api/dashboard_app_time/get-app-time/$childId';
    logger.i('Fetching app time data from $url'); // Info log

    try {
      final response = await http.get(Uri.parse(url));
      logger.i('Response status: ${response.statusCode}'); // Info log
      logger.i('Response body: ${response.body}'); // Log the body of the response

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        logger.i('Fetched allowed time data: $data'); // Info log

        // Prepare allowed time data to include time slots grouped by app name
        Map<String, Map<String, dynamic>> allowedTimeMap = {};

        for (var appData in data) {
          String appName = appData['app_name'] ?? ''; // Default to empty string if null

          // Initialize app entry if it doesn't exist
          if (!allowedTimeMap.containsKey(appName) && appName.isNotEmpty) {
            allowedTimeMap[appName] = {
              'app_name': appName,
              'time_slots': []
            };
          }

          // Check if 'time_slots' exists and is a List before iterating
          var timeSlots = appData['time_slots'] as List<dynamic>?;
          if (timeSlots != null) {
            for (var slot in timeSlots) {
              // Ensure slot is a Map and has the required fields
              if (slot is Map<String, dynamic>) {
                allowedTimeMap[appName]?['time_slots']?.add({
                  'allowed_time': slot['allowed_time'] ?? 0,
                  'start_time': slot['start_time'] ?? '',
                  'end_time': slot['end_time'] ?? ''
                });
              }
            }
          }
        }

        // Convert the map to a list
        List<Map<String, dynamic>> allowedTimeData = allowedTimeMap.values.where((entry) => entry['time_slots']!.isNotEmpty).toList();
        logger.i('Extracted allowed time data: $allowedTimeData'); // Log extracted data
        return allowedTimeData; // Return the list of allowed times
      } else {
        logger.e('Failed to fetch allowed time data: ${response.statusCode} - ${response.body}'); // Error log
        return null;
      }
    } catch (e) {
      logger.e('Exception while fetching allowed time data: $e'); // Error log
      return null;
    }
  }
}
