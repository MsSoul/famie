//filename:child_profile/child_profile_manager.dart (Manages the fetching of child profiles)
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../services/config.dart'; 

class ChildProfileManager {
  final Logger logger = Logger();  // Initialize the logger
  final List<Map<String, String>> _children = [];

 // Function to load children from the server
  Future<bool> loadChildren(String parentId) async {
    logger.i('Loading children for parentId: $parentId');
    _children.clear(); // Clear the children list before loading new data

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/get-children/$parentId'));
      logger.i('Server response status: ${response.statusCode}');
      logger.i('Response Body: ${response.body}'); // Print the body for debugging

      if (response.statusCode == 200) {
        List<dynamic> childrenJson = json.decode(response.body);

        if (childrenJson.isNotEmpty) {
          _children.addAll(
            childrenJson.map((child) {
              // Explicitly casting fields that are strings and handling the ones that are not.
              return {
                'id': child['_id']?.toString() ?? '',
                'name': child['name']?.toString() ?? 'Unknown Name',
                'avatar': child['avatar']?.toString() ?? 'assets/avatar/default_avatar.png',
                'deviceName': child['device_name']?.toString() ?? 'Unknown Device',
                'macAddress': child['mac_address']?.toString() ?? 'Unknown MAC',
                'childId': child['childId']?.toString() ?? '',  
              };
            }).toList().cast<Map<String, String>>(),
          );
          logger.i('Children successfully loaded: $_children');
          return true;
        } else {
          logger.w('No children found for parentId: $parentId');
          return true; // No children but still a successful request
        }
      } else {
        logger.e('Failed to load children. Status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      logger.e('Error loading children: $error');
      return false;
    }
  }

  // Function to get the list of children after loading them
  List<Map<String, String>> getChildren() {
    return _children;
  }


  // Function to add a child via API call and reload children after
  Future<bool> addChild(String parentId, String childId, String name, String avatar, String deviceName, String macAddress) async {
    logger.i('Adding child for parentId: $parentId, childId: $childId, name: $name, avatar: $avatar, deviceName: $deviceName, macAddress: $macAddress');

    // Pre-check for valid inputs before sending the request
    if (name.isEmpty || avatar.isEmpty || deviceName.isEmpty || macAddress.isEmpty || childId.isEmpty) {
      logger.e('One or more fields are empty.');
      return false; // Return failure if any fields are empty
    }

    try {
      // Log the payload before sending the POST request
      logger.i({
        'parentId': parentId,
        'childId': childId,
        'name': name,
        'avatar': avatar,
        'deviceName': deviceName,
        'macAddress': macAddress,
      });

      // Sending a POST request to add a new child profile
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/add-child'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'parentId': parentId,
          'childId': childId,  // Use 'childId' as field name
          'name': name,
          'avatar': avatar,
          'deviceName': deviceName,
          'macAddress': macAddress,
        }),
      );

      // Log the server response for debugging
      logger.i('Server response status: ${response.statusCode}');
      logger.i('Server response body: ${response.body}');

      // Check if the server successfully added the child
      if (response.statusCode == 201) {
        logger.i('Child added successfully: $name');
        await loadChildren(parentId); // Reload the children list after adding the child
        return true; // Success
      } else {
        logger.e('Failed to add child: ${response.body}');
        return false; // Failure
      }
    } catch (error) {
      logger.e('Network error: $error');
      return false; // Failure
    }
  }
}
