//filename:services/app_time_management_service.dart 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'config.dart'; // Import your Config class to get the baseUrl

class AppTimeManagementService {
  final String baseUrl = Config.baseUrl; // Use the base URL from Config
  final Logger _logger = Logger('AppTimeManagementService'); // Initialize the logger

  // Function to save the time schedule
  Future<void> saveTimeSchedule({
    required String appId,
    required String childId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/app_time_management'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'app_id': appId,
          'child_id': childId,
          'time_slots': [
            {
              'start_time': startTime,
              'end_time': endTime,
              'allowed_time': 3600, // Example allowed time, modify as needed
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        _logger.info('Successfully saved time schedule');
      } else {
        _logger.warning('Failed to save time schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error saving time schedule: $e');
    }
  }
}
