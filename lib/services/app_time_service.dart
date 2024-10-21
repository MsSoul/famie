// filename: services/app_time_service.dart
// filename: services/app_time_service.dart
import 'dart:convert';
import 'dart:async';  // Import the correct library for TimeoutException
import 'package:http/http.dart' as http;
import '../services/config.dart';
import 'package:logging/logging.dart';

class AppTimeService {
  final Logger _logger = Logger('AppTimeService');
  final String baseUrl = Config.baseUrl;

  // Fetch app time slots
  Future<List<Map<String, dynamic>>> fetchAppTimeSlots(String appName, String childId) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/fetch_app_time_schedule/$appName?child_id=$childId');

    _logger.info("Requesting app time slots from: $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10)); // Add timeout

      _logger.info("Response Status Code: ${response.statusCode}");
      _logger.info("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _logger.info("Fetched Time Slots Data: $data");
        return data.map((timeSlot) => {
          'start_time': timeSlot['start_time'],
          'end_time': timeSlot['end_time'],
          'allowed_time': timeSlot['allowed_time'],
          'slot_identifier': timeSlot['slot_identifier']
        }).toList();
      } else if (response.statusCode == 404) {
        _logger.warning("No time slots found for appName: $appName and childId: $childId");
        return [];
      } else {
        _logger.warning("Failed to fetch time slots: Status Code ${response.statusCode}");
        return [];
      }
    } on TimeoutException catch (e) {  // Catch TimeoutException first
      _logger.severe("Request timed out: $e");
      return [];
    } on http.ClientException catch (e) {  // Catch ClientException next
      _logger.severe("Client error occurred: $e");
      return [];
    } catch (e, stackTrace) {
      _logger.severe("Error occurred while fetching time slots: $e");
      _logger.severe("Stack Trace: $stackTrace");
      return [];
    }
  }

  // Add time slot
  Future<bool> addTimeSlot(String appName, String childId, String startTime, String endTime) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/add_schedule'); // Adjust the endpoint as necessary

    final body = json.encode({
      'app_name': appName,
      'child_id': childId,
      'start_time': startTime,
      'end_time': endTime,
    });

    _logger.info("Sending POST request to $url with body: $body");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 201) {
        _logger.info("Time slot added successfully");
        return true;
      } else {
        _logger.warning("Failed to add time slot: Status Code ${response.statusCode}");
        return false;
      }
    } on TimeoutException catch (e) {  // Catch TimeoutException first
      _logger.severe("Request timed out: $e");
      return false;
    } on http.ClientException catch (e) {  // Catch ClientException next
      _logger.severe("Client error occurred: $e");
      return false;
    } catch (e) {
      _logger.severe("Error adding time slot: $e");
      return false;
    }
  }

  // Delete time slot
  Future<bool> deleteTimeSlot(String appName, String childId, int index) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/delete_schedule/$appName/$index?child_id=$childId');

    try {
      _logger.info('Sending DELETE request to $url');
      final response = await http.delete(url).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        _logger.info("Time slot deleted successfully");
        return true;
      } else if (response.statusCode == 404) {
        _logger.warning("Time slot not found or already deleted: Status Code ${response.statusCode}");
        return false;
      } else {
        _logger.warning("Failed to delete time slot: Status Code ${response.statusCode}");
        return false;
      }
    } on TimeoutException catch (e) {  // Catch TimeoutException first
      _logger.severe("Request timed out: $e");
      return false;
    } on http.ClientException catch (e) {  // Catch ClientException next
      _logger.severe("Client error occurred: $e");
      return false;
    } catch (e) {
      _logger.severe("Error deleting time slot: $e");
      return false;
    }
  }
}

/*e modify kay ayuson ang pag add schedule
import 'dart:convert';
import 'dart:async';  // Import the correct library for TimeoutException
import 'package:http/http.dart' as http;
import '../services/config.dart';
import 'package:logging/logging.dart';

class AppTimeService {
  final Logger _logger = Logger('AppTimeService');
  final String baseUrl = Config.baseUrl;

  // Fetch app time slots
  Future<List<Map<String, dynamic>>> fetchAppTimeSlots(String appName, String childId) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/fetch_app_time_schedule/$appName?child_id=$childId');

    _logger.info("Requesting app time slots from: $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10)); // Add timeout

      _logger.info("Response Status Code: ${response.statusCode}");
      _logger.info("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _logger.info("Fetched Time Slots Data: $data");
        return data.map((timeSlot) => {
          'start_time': timeSlot['start_time'],
          'end_time': timeSlot['end_time'],
          'allowed_time': timeSlot['allowed_time'],
          'slot_identifier': timeSlot['slot_identifier']
        }).toList();
      } else if (response.statusCode == 404) {
        _logger.warning("No time slots found for appName: $appName and childId: $childId");
        return [];
      } else {
        _logger.warning("Failed to fetch time slots: Status Code ${response.statusCode}");
        return [];
      }
    } on TimeoutException catch (e) {  // Catch TimeoutException first
      _logger.severe("Request timed out: $e");
      return [];
    } on http.ClientException catch (e) {  // Catch ClientException next
      _logger.severe("Client error occurred: $e");
      return [];
    } catch (e, stackTrace) {
      _logger.severe("Error occurred while fetching time slots: $e");
      _logger.severe("Stack Trace: $stackTrace");
      return [];
    }
  }

  // Delete time slot
  Future<bool> deleteTimeSlot(String appName, String childId, int index) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/delete_schedule/$appName/$index?child_id=$childId');

    try {
      _logger.info('Sending DELETE request to $url');
      final response = await http.delete(url).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        _logger.info("Time slot deleted successfully");
        return true;
      } else if (response.statusCode == 404) {
        _logger.warning("Time slot not found or already deleted: Status Code ${response.statusCode}");
        return false;
      } else {
        _logger.warning("Failed to delete time slot: Status Code ${response.statusCode}");
        return false;
      }
    } on TimeoutException catch (e) {  // Catch TimeoutException first
      _logger.severe("Request timed out: $e");
      return false;
    } on http.ClientException catch (e) {  // Catch ClientException next
      _logger.severe("Client error occurred: $e");
      return false;
    } catch (e) {
      _logger.severe("Error deleting time slot: $e");
      return false;
    }
  }
}
*/
/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/config.dart';
//import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class AppTimeService {
  final Logger _logger = Logger('AppTimeService');
  final String baseUrl = Config.baseUrl;

  // Fetch app time slots
  Future<List<Map<String, dynamic>>> fetchAppTimeSlots(String appName, String childId) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/fetch_app_time_schedule/$appName?child_id=$childId');

    _logger.info("Requesting app time slots from: $url");

    try {
      final response = await http.get(url);

      _logger.info("Response Status Code: ${response.statusCode}");
      _logger.info("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _logger.info("Fetched Time Slots Data: $data");
        return data.map((timeSlot) => {
          'start_time': timeSlot['start_time'],
          'end_time': timeSlot['end_time'],
          'allowed_time': timeSlot['allowed_time'],
          'slot_identifier': timeSlot['slot_identifier']
        }).toList();
      } else {
        _logger.warning("Failed to fetch time slots for appName: $appName and childId: $childId");
        return [];
      }
    } catch (e, stackTrace) {
      _logger.severe("Error occurred while fetching time slots: $e");
      _logger.severe("Stack Trace: $stackTrace");
      return [];
    }
  }
// Delete time slot
Future<void> deleteTimeSlot(String appName, String childId, int index) async {
  // Construct the URL with appName, index, and childId as a query parameter
  final url = Uri.parse('$baseUrl/api/app_time_management/delete_schedule/$appName/$index?child_id=$childId');

  try {
    _logger.info('Sending DELETE request to $url');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      _logger.info("Time slot deleted successfully");
    } else {
      _logger.warning("Failed to delete time slot: Status Code ${response.statusCode}");
      _logger.warning("Response Body: ${response.body}");
    }
  } catch (e) {
    _logger.severe("Error deleting time slot: $e");
  }
}
}*/
/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/config.dart'; // Assuming Config holds the base URL for the API
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class AppTimeService {
  final Logger _logger = Logger('AppTimeService');
  final String baseUrl = Config.baseUrl;

  // Fetch app time slots for a specific app and child
  Future<List<Map<String, dynamic>>> fetchAppTimeSlots(String appId, String childId) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/fetch_app_time_schedule/$appId?child_id=$childId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((timeSlot) => {
          'start_time': timeSlot['start_time'],
          'end_time': timeSlot['end_time'],
          'allowed_time': timeSlot['allowed_time'],
          'slot_identifier': timeSlot['slot_identifier']
        }).toList();
      } else {
        _logger.warning("Error: Failed to fetch time slots for appId: $appId and childId: $childId");
        return [];
      }
    } catch (e) {
      _logger.severe("Error fetching time slots: $e");
      return [];
    }
  }

  // Add a new time slot
  Future<void> addNewTimeSlot(BuildContext context, String appId, String childId, List<Map<String, String>> timeSlots) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/save_schedule/$appId');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'childId': childId,
      'timeSlots': timeSlots,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.info("Time slot added successfully for appId: $appId and childId: $childId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot added successfully')),
        );
      } else {
        _logger.warning("Failed to add time slot for appId: $appId and childId: $childId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add time slot')),
        );
      }
    } catch (e) {
      _logger.severe("Error adding time slot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding time slot: $e')),
      );
    }
  }

  // Edit an existing time slot
  Future<void> editTimeSlot(BuildContext context, String appId, String childId, List<Map<String, String>> timeSlots, int index) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/update_schedule/$appId');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'childId': childId,
      'timeSlot': timeSlots[index],
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        _logger.info("Time slot updated successfully for appId: $appId and childId: $childId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot updated successfully')),
        );
      } else {
        _logger.warning("Failed to update time slot for appId: $appId and childId: $childId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update time slot')),
        );
      }
    } catch (e) {
      _logger.severe("Error updating time slot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating time slot: $e')),
      );
    }
  }

  // Delete an existing time slot
  Future<void> deleteTimeSlot(String appId, String childId, int index) async {
    final url = Uri.parse('$baseUrl/api/app_time_management/delete_schedule/$appId/$index');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        _logger.info("Time slot deleted successfully for appId: $appId and childId: $childId");
      } else {
        _logger.warning("Failed to delete time slot for appId: $appId and childId: $childId");
      }
    } catch (e) {
      _logger.severe("Error deleting time slot: $e");
    }
  }
}
*/