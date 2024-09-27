//filename:services/app_toggle_service.dart (sa toggle service pag save sa data sa toggle)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:logging/logging.dart';

class AppToggleService {
  final String baseUrl = Config.baseUrl;
  final Logger _logger = Logger('AppToggleService');

  // Update the app toggle status in the app_management collection
  Future<void> updateAppToggleStatus(String packageName, bool isAllowed, String childId, String parentId) async {
    final url = Uri.parse('$baseUrl/api/app_management/update_app_management/$packageName');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'childId': childId,
      'parentId': parentId,
      'isAllowed': isAllowed,
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update toggle status');
    }
  }
  /*Future<void> updateAppToggleStatus(String packageName, bool isAllowed, String childId, String parentId) async {
    try {
      final url = Uri.parse('$baseUrl/api/app_management/update_app_management/$packageName');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'childId': childId,
        'parentId': parentId,
        'isAllowed': isAllowed,
      });

      _logger.info('Sending POST request to $url with body: $body');

      // Send POST request to backend
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Log the response
      _logger.info('Response Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Successfully updated toggle status for packageName: $packageName with isAllowed: $isAllowed');
      } else {
        _logger.severe('Failed to update toggle status for packageName: $packageName. Status code: ${response.statusCode}');
        throw Exception('Failed to update toggle status');
      }
    } catch (e) {
      _logger.severe('Error updating app toggle status: $e');
      throw Exception('Error updating app toggle status: $e');
    }
  }*/

  // Save the time schedule for an app in app_time_management collection
  Future<void> saveTimeSchedule(String packageName, String childId, List<Map<String, String>> timeSlots) async {
    try {
      final url = Uri.parse('$baseUrl/api/app_time_management/save_schedule/$packageName');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'childId': childId,
        'timeSlots': timeSlots,  // Pass time slots here to be saved in the app_time_management collection
      });

      _logger.info('Sending POST request to $url with body: $body');

      // Send POST request to backend
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Log the response
      _logger.info('Response Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Successfully saved time schedule for packageName: $packageName');
      } else {
        _logger.severe('Failed to save time schedule for packageName: $packageName. Status code: ${response.statusCode}');
        throw Exception('Failed to save time schedule');
      }
    } catch (e) {
      _logger.severe('Error saving time schedule: $e');
      throw Exception('Error saving time schedule: $e');
    }
  }
}

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:logging/logging.dart';

class AppToggleService {
  final String baseUrl = Config.baseUrl;
  final Logger _logger = Logger('AppToggleService');

  // Update the app toggle status in the app_management collection
  Future<void> updateAppToggleStatus(String packageName, bool isAllowed, String childId, String parentId) async {
    try {
      final url = Uri.parse('$baseUrl/api/app_management/update_app_management/$packageName');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'childId': childId,
        'parentId': parentId,
        'isAllowed': isAllowed,
      });

      _logger.info('Sending POST request to $url with body: $body');

      // Send POST request to backend
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Log the response
      _logger.info('Response Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Successfully updated toggle status for packageName: $packageName with isAllowed: $isAllowed');
      } else {
        _logger.severe('Failed to update toggle status for packageName: $packageName. Status code: ${response.statusCode}');
        throw Exception('Failed to update toggle status');
      }
    } catch (e) {
      _logger.severe('Error updating app toggle status: $e');
      throw Exception('Error updating app toggle status: $e');
    }
  }

  // Save the time schedule for an app in app_time_management collection
  Future<void> saveTimeSchedule(String packageName, String childId, List<Map<String, String>> timeSlots) async {
    try {
      final url = Uri.parse('$baseUrl/api/app_time_management/save_schedule/$packageName');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'childId': childId,
        'timeSlots': timeSlots,  // Pass time slots here to be saved in the app_time_management collection
      });

      _logger.info('Sending POST request to $url with body: $body');

      // Send POST request to backend
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Log the response
      _logger.info('Response Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Successfully saved time schedule for packageName: $packageName');
      } else {
        _logger.severe('Failed to save time schedule for packageName: $packageName. Status code: ${response.statusCode}');
        throw Exception('Failed to save time schedule');
      }
    } catch (e) {
      _logger.severe('Error saving time schedule: $e');
      throw Exception('Error saving time schedule: $e');
    }
  }
}
*/