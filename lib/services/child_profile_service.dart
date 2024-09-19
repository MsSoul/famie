//filename:service/child_profile_Service.dart (api servervice sa child profile registartion)
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'dart:io';
import '../services/config.dart'; // Import your config file

class ChildProfileService {
  final Logger logger = Logger();
  final Duration timeoutDuration = const Duration(seconds: 20); // Timeout for all requests

  // Register child function
  Future<bool> registerChild(String parentId, String childId, String name, String avatar, String deviceName, String macAddress) async {
    final url = Uri.parse('${Config.baseUrl}/add-child');

    // Log the payload data before sending the request
    logger.i('Registering child with the following details:');
    logger.i('parentId: $parentId');
    logger.i('childId: $childId');
    logger.i('name: $name');
    logger.i('avatar: $avatar');
    logger.i('deviceName: $deviceName');
    logger.i('macAddress: $macAddress');

    // Ensure a fallback for missing macAddress
    if (macAddress == "Unknown" || macAddress.isEmpty) {
      macAddress = "Not provided";
      logger.w("macAddress is missing, using fallback: $macAddress");
    }

    // Pre-check for missing fields
    if (parentId.isEmpty || childId.isEmpty || name.isEmpty || avatar.isEmpty || deviceName.isEmpty) {
      logger.e('Missing fields in the request');
      return false; // Return early if any required fields are missing
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'parentId': parentId, // Ensure the parentId is correctly passed as a string
          'childId': childId,
          'name': name,
          'avatar': avatar,
          'deviceName': deviceName,
          'macAddress': macAddress,
        }),
      ).timeout(timeoutDuration);

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 201) {
        logger.i('Child registered successfully');
        return true;
      } else {
        logger.e('Failed to register child: ${response.body}');
        return false;
      }
    } on SocketException {
      logger.e('No internet connection');
      throw Exception('No internet connection. Please try again.');
    } on TimeoutException {
      logger.e('Register child request timed out');
      throw Exception('Request timed out. Please try again.');
    } catch (e, stackTrace) {
      logger.e('Error during child registration: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Load child profiles function
  Future<List<Map<String, dynamic>>> loadChildren(String parentId) async {
    final url = Uri.parse('${Config.baseUrl}/get-children/$parentId');

    try {
      final response = await http.get(url).timeout(timeoutDuration);

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> children = List<Map<String, dynamic>>.from(data);
        return children;
      } else {
        logger.e('Failed to load children: ${response.body}');
        return [];
      }
    } on SocketException {
      logger.e('No internet connection');
      throw Exception('No internet connection. Please try again.');
    } on TimeoutException {
      logger.e('Load children request timed out');
      throw Exception('Request timed out. Please try again.');
    } catch (e, stackTrace) {
      logger.e('Error loading children: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }
}

/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'config.dart'; // Import the config file

class ChildProfileService {
  final Logger logger = Logger();
  final Duration timeoutDuration = const Duration(seconds: 20); // Timeout for all requests

  // Register child function
  Future<bool> registerChild(String parentId, String childId, String name, String avatar, String deviceName, String macAddress) async {
    final url = Uri.parse('${Config.baseUrl}/add-child');

    // Log the payload data before sending the request
    logger.i('Registering child with the following details:');
    logger.i('parentId: $parentId');
    logger.i('childId: $childId');
    logger.i('name: $name');
    logger.i('avatar: $avatar');
    logger.i('deviceName: $deviceName');
    logger.i('macAddress: $macAddress');

    // Check for missing fields and log specific field
    if (parentId.isEmpty) {
      logger.e('Missing parentId');
    }
    if (childId.isEmpty) {
      logger.e('Missing childId');
    }
    if (name.isEmpty) {
      logger.e('Missing name');
    }
    if (avatar.isEmpty) {
      logger.e('Missing avatar');
    }
    if (deviceName.isEmpty) {
      logger.e('Missing deviceName');
    }
    if (macAddress.isEmpty) {
      logger.e('Missing macAddress');
    }

    // Pre-check for missing fields
    if (parentId.isEmpty || childId.isEmpty || name.isEmpty || avatar.isEmpty || deviceName.isEmpty || macAddress.isEmpty) {
      logger.e('Missing fields in the request');
      return false; // Return early if any required fields are missing
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'parentId': parentId,
          'childId': childId,   // Ensure this is being sent
          'name': name,
          'avatar': avatar,
          'deviceName': deviceName,
          'macAddress': macAddress,
        }),
      ).timeout(timeoutDuration);

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 201) {
        logger.i('Child registered successfully');
        return true;
      } else {
        logger.e('Failed to register child: ${response.body}');
        return false;
      }
    } on SocketException {
      logger.e('No internet connection');
      throw Exception('No internet connection. Please try again.');
    } on TimeoutException {
      logger.e('Register child request timed out');
      throw Exception('Request timed out. Please try again.');
    } catch (e, stackTrace) {
      logger.e('Error during child registration: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

*/