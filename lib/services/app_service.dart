//filename:services/app_service.dart (fetching app list)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart'; // Ensure you have Config.baseUrl set
import 'package:logging/logging.dart';

class AppService {
  final String baseUrl = Config.baseUrl; // Use the base URL from your config
  final Logger _logger = Logger('AppService');

  // Sync apps from app_list to app_management
  Future<void> syncAppManagement(String childId, String parentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/app_management/sync_app_management?child_id=$childId&parent_id=$parentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _logger.info('Successfully synced apps for childId: $childId');
      } else {
        _logger.severe('Failed to sync apps for childId: $childId. Status code: ${response.statusCode}');
        throw Exception('Failed to sync apps');
      }
    } catch (e) {
      _logger.severe('Error syncing apps for childId: $childId', e);
      throw Exception('Error syncing apps');
    }
  }

  // Fetch apps from app_management collection
  Future<List<Map<String, dynamic>>> fetchAppManagement(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/app_management/fetch_app_management?child_id=$childId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _logger.info('Successfully fetched apps for childId: $childId');
        List<dynamic> appData = jsonDecode(response.body);
        return appData.map((app) => {
              '_id': app['_id'],
              'app_name': app['app_name'],
              'package_name': app['package_name'],
              'is_allowed': app['is_allowed'],
            }).toList();
      } else if (response.statusCode == 404) {
        _logger.warning('No apps found for childId: $childId');
        return []; // Return an empty list if no apps are found
      } else {
        _logger.severe('Failed to fetch apps for childId: $childId. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch apps');
      }
    } catch (e) {
      _logger.severe('Error fetching app management list for childId: $childId', e);
      throw Exception('Error fetching app management list');
    }
  }
}


/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart'; // Import your Config for baseUrl
import 'package:logger/logger.dart'; // Import the Logger package

class AppService {
  final String baseUrl = Config.baseUrl; // Use Config.baseUrl for the base URL
  final Logger _logger = Logger(); // Initialize the Logger

  // Fetch the app list for a specific childId
  Future<List<Map<String, dynamic>>> fetchAppList(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/app_management/app_list?child_id=$childId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _logger.i('Successfully retrieved app list for childId: $childId'); // Log success
        List<dynamic> appData = jsonDecode(response.body);

        // Return the list of apps, including the is_allowed status
        return appData.map((app) => {
          '_id': app['_id'],
          'app_name': app['app_name'],
          'package_name': app['package_name'],
          'is_allowed': app['is_allowed'], // is_allowed comes from app_management
        }).toList();
      } else {
        _logger.e('Failed to retrieve app list for childId: $childId. Status code: ${response.statusCode}');
        throw Exception('Failed to load apps');
      }
    } catch (e) {
      _logger.e('Error fetching app list: $e');
      throw Exception('Error fetching app list');
    }
  }

  // Post the toggle status of an app to the app_management collection
  Future<void> updateAppToggleStatus(String appId, bool isAllowed, String childId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/app_management/$appId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'childId': childId,
          'isAllowed': isAllowed,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Successfully updated toggle status for appId: $appId');
      } else {
        _logger.e('Failed to update toggle status for appId: $appId. Status code: ${response.statusCode}');
        throw Exception('Failed to update toggle status');
      }
    } catch (e) {
      _logger.e('Error updating app toggle status: $e');
      throw Exception('Error updating app toggle status');
    }
  }
}
*/
/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart'; // Import your Config
import 'package:logger/logger.dart'; // Import the Logger package

class AppService {
  final String baseUrl = Config.baseUrl; // Use Config.baseUrl for the base URL
  final Logger _logger = Logger(); // Initialize the Logger

  // Fetch the app list for a specific childId from the app_list collection
  Future<List<Map<String, dynamic>>> fetchAppList(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/app_management/app_list?child_id=$childId')

, // Adjust API endpoint as needed
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      _logger.i('Successfully retrieved app list for childId: $childId'); // Log success using Logger
      List<dynamic> appData = jsonDecode(response.body);
      return appData.map((app) => {
        '_id': app['_id'],
        'app_name': app['app_name'],
        'package_name': app['package_name'],
      }).toList();
    } else {
      _logger.e('Failed to retrieve app list for childId: $childId. Status code: ${response.statusCode}');
      throw Exception('Failed to load apps');
    }
  }
}
*/