//filename:child_profile/child_profile_manager.dart (Manages the fetching of child profiles)
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import '../services/config.dart'; // Import your config.dart file here

class ChildProfileManager {
  final Logger logger = Logger('ChildProfileManager');
  final List<Map<String, String>> _children = [];

  // Function to load children from the server
  Future<bool> loadChildren(String parentId) async {
  logger.info('Loading children for parentId: $parentId');
  _children.clear(); // Clear the children list before loading new data

  try {
    final response = await http.get(Uri.parse('${Config.baseUrl}/get-children/$parentId'));
    logger.info('Server response status: ${response.statusCode}');
    logger.info('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> childrenJson = json.decode(response.body);

      if (childrenJson.isNotEmpty) {
        _children.addAll(
          childrenJson.map((child) {
            return {
              'id': child['_id']?.toString() ?? '',
              'name': child['name'] ?? 'Unknown Name',
              'avatar': child['avatar'] ?? 'assets/avatar/default_avatar.png',
              'deviceName': child['device_name'] ?? 'Unknown Device',
              'macAddress': child['mac_address'] ?? 'Unknown MAC',
              'child_id': child['child_id']?.toString() ?? '',
            };
          }).toList().cast<Map<String, String>>(),
        );
        logger.info('Children successfully loaded: $_children');
        return true;
      } else {
        logger.warning('No children found for parentId: $parentId');
        return true; // No children but still successful request
      }
    } else {
      logger.severe('Failed to load children. Status code: ${response.statusCode}');
      return false;
    }
  } catch (error) {
    logger.severe('Error loading children: $error');
    return false;
  }
}
  // Function to get the list of children after loading them
  List<Map<String, String>> getChildren() {
    return _children;
  }

  // Function to add a child via API call and reload children after
  Future<bool> addChild(String parentId, String childId, String name, String avatar, String deviceName, String macAddress) async {
    logger.info('Adding child for parentId: $parentId, childId: $childId, name: $name, avatar: $avatar, deviceName: $deviceName, macAddress: $macAddress');
    
    // Pre-check for valid inputs before sending the request
    if (name.isEmpty || avatar.isEmpty || deviceName.isEmpty || macAddress.isEmpty || childId.isEmpty) {
      logger.severe('One or more fields are empty.');
      return false; // Return failure if any fields are empty
    }

    try {
      // Sending a POST request to add a new child profile
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/add-child'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'parentId': parentId,
          'childId': childId,
          'name': name,
          'avatar': avatar,
          'deviceName': deviceName,
          'macAddress': macAddress,
        }),
      );

      // Log the server response for debugging
      logger.info('Server response status: ${response.statusCode}');
      logger.info('Server response body: ${response.body}');
      
      // Check if the server successfully added the child
      if (response.statusCode == 201) {
        logger.info('Child added successfully: $name');
        await loadChildren(parentId); // Reload the children list after adding the child
        return true; // Success
      } else {
        logger.severe('Failed to add child: ${response.body}');
        return false; // Failure
      }
    } catch (error) {
      logger.severe('Network error: $error');
      return false; // Failure
    }
  }

  // Function to fetch app time limits for a child
  Future<List<Map<String, dynamic>>> getAppTimeLimits(String childId) async {
    logger.info('Loading app time limits for childId: $childId');
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/get-app-time-limits/$childId'));

      logger.info('Server response status: ${response.statusCode}');
      logger.info('Server response body: ${response.body}');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        logger.severe('Failed to load app time limits from server. Status code: ${response.statusCode}, Body: ${response.body}');
        return [];
      }
    } catch (error) {
      logger.severe('Network error: $error');
      return [];
    }
  }

  // Function to fetch screen time limits for a child
  Future<List<Map<String, dynamic>>> getScreenTimeLimits(String childId) async {
    logger.info('Loading screen time limits for childId: $childId');
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/get-screen-time-limits/$childId'));

      logger.info('Server response status: ${response.statusCode}');
      logger.info('Server response body: ${response.body}');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        logger.severe('Failed to load screen time limits from server. Status code: ${response.statusCode}, Body: ${response.body}');
        return [];
      }
    } catch (error) {
      logger.severe('Network error: $error');
      return [];
    }
  }
}
