//filename:services/app_toggle_service.dart (sa toggle service pag save sa data sa toggle)
/// filename: services/app_toggle_service.dart (service for toggling and saving schedule data)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AppToggleService {
  final Logger _logger = Logger('AppToggleService');
  final Uuid uuid = Uuid();

  Future<void> updateAppToggleStatus(String packageName, bool isAllowed, String childId, String parentId) async {
    final url = Uri.parse('${Config.baseUrl}/api/app_management/update_app_management/$packageName');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'childId': childId,
      'parentId': parentId,
      'isAllowed': isAllowed,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      _logger.info('Response Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update toggle status: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error updating toggle status: $e');
      throw Exception('Error updating toggle status: $e');
    }
  }

  Future<List<Map<String, String>>> fetchAllowedTimeSlots(String childId) async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/app_time_management/allowed_slots/$childId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ensure each map in the list is correctly converted to Map<String, String>
        final List<Map<String, String>> allowedSlots = (data['allowed_slots'] as List<dynamic>).map((slot) {
          return {
            'start_time': slot['start_time']?.toString() ?? '',
            'end_time': slot['end_time']?.toString() ?? '',
          };
        }).toList();

        return allowedSlots;
      } else {
        throw Exception('Failed to fetch allowed time slots: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error fetching allowed time slots: $e');
      throw Exception('Error fetching allowed time slots: $e');
    }
  }

  TimeOfDay parseTime(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
      hour += 12; // Convert PM hour
    }
    if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
      hour = 0; // Convert 12 AM to 0
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  bool isScheduleValid(List<Map<String, String>> providedSlots, List<Map<String, String>> allowedSlots) {
    for (var provided in providedSlots) {
      final startProvided = parseTime(provided['start_time']!);
      final endProvided = parseTime(provided['end_time']!);

      bool isValid = false;

      for (var allowed in allowedSlots) {
        final startAllowed = parseTime(allowed['start_time']!);
        final endAllowed = parseTime(allowed['end_time']!);

        // Check if the provided time slot falls within the allowed time slot
        if ((startProvided.hour > startAllowed.hour ||
            (startProvided.hour == startAllowed.hour && startProvided.minute >= startAllowed.minute)) &&
            (endProvided.hour < endAllowed.hour ||
            (endProvided.hour == endAllowed.hour && endProvided.minute <= endAllowed.minute))) {
          isValid = true; // Valid schedule found
          break; // Exit loop once a valid slot is found
        }
      }

      if (!isValid) {
        return false; // Invalid slot found
      }
    }
    return true; // All provided slots are valid
  }

  Future<void> saveTimeSchedule(String appName, String childId, List<Map<String, String>> newTimeSlots) async {
    final url = Uri.parse('${Config.baseUrl}/api/app_time_management/save_schedule/$appName');
    final headers = {
      'Content-Type': 'application/json',
    };

    // Log the data being sent
    _logger.info('Preparing to send request to save time schedule with the following data:');
    _logger.info('Child ID: $childId');
    _logger.info('App Name: $appName');
    _logger.info('New Time Slots: ${newTimeSlots.map((slot) => slot.toString()).toList()}');

    // Fetch allowed slots for validation
    final allowedSlots = await fetchAllowedTimeSlots(childId);

    // Validate the new time slots against allowed time slots
    if (!isScheduleValid(newTimeSlots, allowedSlots)) {
      _logger.warning('Provided time slots do not fall within allowed screen time ranges');
      throw Exception('Provided time slots do not fall within allowed screen time ranges');
    }

    // Prepare body data for the backend
    final body = jsonEncode({
      'childId': childId,
      'timeSlots': newTimeSlots.map((slot) {
        return {
          'start_time': slot['start_time'],
          'end_time': slot['end_time'],
        };
      }).toList(),
    });

    // Log the entire request body
    _logger.info('Request body: $body');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Log the response status and body
      _logger.info('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Time schedule saved successfully.');
      } else {
        throw Exception('Failed to save time schedule: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error saving time schedule: $e');
      throw Exception('Error saving time schedule: $e');
    }
  }
}


/*working and fetch schdule ani para mag  validate
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'config.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

class AppToggleService {
  final Logger _logger = Logger('AppToggleService');

  // Update the app toggle status in the app_management collection
  Future<void> updateAppToggleStatus(String packageName, bool isAllowed, String childId, String parentId) async {
    final url = Uri.parse('${Config.baseUrl}/api/app_management/update_app_management/$packageName');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'childId': childId,
      'parentId': parentId,
      'isAllowed': isAllowed,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Log the response status and body
      _logger.info('Response Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update toggle status: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error updating toggle status: $e');
      throw Exception('Error updating toggle status: $e');
    }
  }

  Future<List<Map<String, String>>> fetchAllowedTimeSlots(String childId) async {
  try {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/app_time_management/allowed_slots/$childId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Assuming each time slot is a Map<String, String>
      final List<Map<String, String>> allowedSlots = List<Map<String, String>>.from(data['allowed_slots']);
      return allowedSlots;
    } else {
      throw Exception('Failed to load allowed time slots: ${response.body}');
    }
  } catch (e) {
    print('Error fetching allowed time slots: $e');
    throw e;
  }
}

  // Validate the time schedule against allowed time slots
  bool isScheduleValid(TimeOfDay start, TimeOfDay end, List<Map<String, String>> allowedSlots) {
    for (var slot in allowedSlots) {
      var startParts = slot['start_time']!.split(':');
      var endParts = slot['end_time']!.split(':');
      var allowedStart = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      var allowedEnd = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));

      // Check if the selected times are within the allowed ranges
      if ((start.hour > allowedStart.hour || 
          (start.hour == allowedStart.hour && start.minute >= allowedStart.minute)) &&
          (end.hour < allowedEnd.hour || 
          (end.hour == allowedEnd.hour && end.minute <= allowedEnd.minute))) {
        return true; // Valid schedule found
      }
    }

    return false; // No valid schedule found
  }

  // Save the time schedule for an app in app_time_management collection
  Future<void> saveTimeSchedule(String packageName, String childId, List<Map<String, String>> timeSlots) async {
    if (timeSlots.isEmpty) {
      throw Exception('No time slots provided');
    }

    try {
      // Fetch allowed time slots for validation
      final allowedSlots = await fetchAllowedTimeSlots(childId);

      // Validate each time slot
      for (var timeSlot in timeSlots) {
        final startTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(timeSlot['start_time']!));
        final endTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(timeSlot['end_time']!));

        if (!isScheduleValid(startTime, endTime, allowedSlots)) {
          throw Exception('Invalid time schedule for start time: ${timeSlot['start_time']} and end time: ${timeSlot['end_time']}');
        }
      }

      final url = Uri.parse('${Config.baseUrl}/api/app_time_management/save_schedule/$packageName');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'childId': childId,
        'timeSlots': timeSlots, // Pass time slots here to be saved in the app_time_management collection
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
        throw Exception('Failed to save time schedule: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error saving time schedule: $e');
      throw Exception('Error saving time schedule: $e');
    }
  }
}

*/
/*
e update kay  butangan ug is valid
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