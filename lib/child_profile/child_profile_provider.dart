//filename: child_profile/child_profile_provider.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/config.dart';

class ChildProfileProvider extends ChangeNotifier {
  final Logger logger = Logger();
  final List<Map<String, String>> _children = [];
  bool _isDataLoaded = false;  
  bool _isLoading = false;     
  String? _selectedChildId;   

  List<Map<String, String>> get children => _children; // Getter for children
  bool get isLoading => _isLoading; // Getter for the loading state
  String? get selectedChildId => _selectedChildId; // Getter for selected child ID

  // Setter for selected child ID
  void setSelectedChildId(String childId) {
    _selectedChildId = childId;
    notifyListeners(); // Notify listeners when a child is selected
  }

  Future<void> loadChildren(String parentId) async {
    if (_isDataLoaded) {
      logger.i('Children data is already loaded, skipping API call');
      return;  // Return early if data is already loaded
    }

    _isLoading = true;  // Set loading state to true
    notifyListeners();  // Notify listeners about loading state

    logger.i('Loading children for parentId: $parentId');
    _children.clear();  // Clear the list only when data is being fetched from the server

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/get-children/$parentId'));
      logger.i('Server response status: ${response.statusCode}');
      logger.i('Response Body: ${response.body}');  // Print the body for debugging

      if (response.statusCode == 200) {
        List<dynamic> childrenJson = json.decode(response.body);

        if (childrenJson.isNotEmpty) {
          _children.addAll(
            childrenJson.map((child) {
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
          _isDataLoaded = true;  // Set the flag to indicate data has been loaded
        }
      } else {
        logger.e('Failed to load children. Status code: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error loading children: $error');
    } finally {
      _isLoading = false;  // Set loading state to false after fetching
      notifyListeners();   // Notify listeners when data changes
    }
  }
}

/*
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/config.dart';

class ChildProfileProvider extends ChangeNotifier {
  final Logger logger = Logger();
  final List<Map<String, String>> _children = [];
  bool _isDataLoaded = false;  // Check if data is already loaded
  bool _isLoading = false;     // New loading state to manage loading spinner

  List<Map<String, String>> get children => _children; // Getter for children
  bool get isLoading => _isLoading; // Getter for the loading state

  Future<void> loadChildren(String parentId) async {
    if (_isDataLoaded) {
      logger.i('Children data is already loaded, skipping API call');
      return;  // Return early if data is already loaded
    }

    _isLoading = true;  // Set loading state to true
    notifyListeners();  // Notify listeners about loading state

    logger.i('Loading children for parentId: $parentId');
    _children.clear();  // Clear the list only when data is being fetched from the server

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/get-children/$parentId'));
      logger.i('Server response status: ${response.statusCode}');
      logger.i('Response Body: ${response.body}');  // Print the body for debugging

      if (response.statusCode == 200) {
        List<dynamic> childrenJson = json.decode(response.body);

        if (childrenJson.isNotEmpty) {
          _children.addAll(
            childrenJson.map((child) {
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
          _isDataLoaded = true;  // Set the flag to indicate data has been loaded
        }
      } else {
        logger.e('Failed to load children. Status code: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error loading children: $error');
    } finally {
      _isLoading = false;  // Set loading state to false after fetching
      notifyListeners();   // Notify listeners when data changes
    }
  }
}*/

/*
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/config.dart';

class ChildProfileProvider extends ChangeNotifier {
  final Logger logger = Logger();
  final List<Map<String, String>> _children = [];
  bool _isDataLoaded = false;  // Check if data is already loaded

  List<Map<String, String>> get children => _children; // Getter for children

  Future<void> loadChildren(String parentId) async {
    if (_isDataLoaded) {
      logger.i('Children data is already loaded, skipping API call');
      return;  // Return early if data is already loaded
    }

    logger.i('Loading children for parentId: $parentId');
    _children.clear();  // Clear the list only when data is being fetched from the server

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/get-children/$parentId'));
      logger.i('Server response status: ${response.statusCode}');
      logger.i('Response Body: ${response.body}');  // Print the body for debugging

      if (response.statusCode == 200) {
        List<dynamic> childrenJson = json.decode(response.body);

        if (childrenJson.isNotEmpty) {
          _children.addAll(
            childrenJson.map((child) {
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
          _isDataLoaded = true;  // Set the flag to indicate data has been loaded
          notifyListeners();  // Notify listeners when data changes
        }
      } else {
        logger.e('Failed to load children. Status code: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error loading children: $error');
    }
  }
}
*/