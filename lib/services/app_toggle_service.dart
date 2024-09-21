//filename:services/app_toggle_service.dart 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart'; // Import logging package
import 'config.dart'; // Import your Config class to get the baseUrl

class AppToggleService {
  final String baseUrl = Config.baseUrl; // Use Config.baseUrl for the base URL
  final Logger _logger = Logger('AppToggleService'); // Initialize the Logger

  // Function to update the toggle status of an app in app_management
  Future<void> updateAppToggleStatus(String appId, bool isAllowed, String childId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/app_management/$appId'), // POST request to the backend API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'childId': childId, // Child ID to associate with the app
          'isAllowed': isAllowed, // Whether the app is allowed or not
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success: The app toggle was successfully updated or created in app_management
        _logger.info('Successfully updated app toggle status for appId: $appId');
      } else {
        // Error: Failed to update app toggle status
        _logger.warning('Failed to update app toggle status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any errors that occur during the HTTP request
      _logger.severe('Error updating app toggle status: $e');
    }
  }

  // Fetch the app management data for a specific child from app_management collection (if needed)
  /*Future<List<Map<String, dynamic>>> fetchAppManagementList(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/app_management?child_id=$childId'), // Fetch app data by childId
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Successfully fetched data
        List<dynamic> appData = jsonDecode(response.body);
        _logger.info('Successfully fetched app management list for childId: $childId');
        return appData.map((app) => {
          '_id': app['_id'],
          'app_name': app['app_name'],
          'is_allowed': app['is_allowed'] ?? false, // Get the allowed status from app_management
        }).toList();
      } else {
        // Error: Failed to fetch data
        _logger.warning('Failed to fetch app management list. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch app management list');
      }
    } catch (e) {
      // Catch any errors that occur during the HTTP request
      _logger.severe('Error fetching app management list: $e');
      throw Exception('Error fetching app management list');
    }
  }*/
}

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart'; // Import the logging package
import 'config.dart'; // Import your Config class to get the baseUrl

class AppToggleService {
  final String baseUrl = Config.baseUrl; // Use Config.baseUrl for the base URL
  final Logger _logger = Logger('AppToggleService'); // Initialize the logger

  // Function to update the toggle status of an app in app_management
  Future<void> updateAppToggleStatus(String appId, bool isAllowed) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/app_management/$appId'), // Assuming this is your update route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'is_allowed': isAllowed}), // Send whether the app is allowed or not
      );

      if (response.statusCode == 200) {
        _logger.info('Successfully updated app toggle status');
      } else {
        _logger.warning('Failed to update app toggle status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error updating app toggle status: $e');
    }
  }

  // Fetch the app management data for a specific child from app_management collection
  Future<List<Map<String, dynamic>>> fetchAppManagementList(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/app_management?child_id=$childId'), // Assuming this is your fetch route
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> appData = jsonDecode(response.body);
        return appData.map((app) => {
          '_id': app['_id'],
          'app_name': app['app_name'],
          'is_allowed': app['is_allowed'] ?? false, // Fetch the allowed status from app_management
        }).toList();
      } else {
        throw Exception('Failed to fetch app management list');
      }
    } catch (e) {
      _logger.severe('Error fetching app management list: $e');
      throw Exception('Error fetching app management list');
    }
  }
}
*/