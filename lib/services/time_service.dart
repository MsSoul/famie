//fiilename:services/time_service.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../set_time_limit/time_schedule_dialog.dart';
import '../design/notification_prompts.dart'; // Import notification prompts
import 'config.dart';

final Logger logger = Logger();

// Helper to convert TimeOfDay to DateTime
DateTime convertTimeOfDayToDateTime(TimeOfDay time) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, time.hour, time.minute);
}

class TimeService {
  // Save time management for a child
  Future<void> saveTimeManagement(String childId, List<Map<String, String>> timeSlots) async {
    try {
      logger.i('Saving time management for child: $childId, Time slots: $timeSlots');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/time_management/$childId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'time_slots': timeSlots,
        }),
      );

      if (response.statusCode == 200) {
        logger.i('Time management data saved successfully');
      } else {
        logger.e('Failed to save time management data. Error: ${response.body}');
        throw Exception('Error saving time management data.');
      }
    } catch (e) {
      logger.e('Error saving time management data: $e');
      rethrow;
    }
  }

  // Fetch time slots for a child
  Future<List<Map<String, dynamic>>> fetchTimeSlots(String childId) async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/time_management/$childId'));

      if (response.statusCode == 200) {
        final List<dynamic> timeSlots = jsonDecode(response.body);
        return timeSlots.map((slot) => Map<String, dynamic>.from(slot)).toList();
      } else {
        throw Exception('Error fetching time slots.');
      }
    } catch (error) {
      logger.e('Error fetching time slots: $error');
      throw Exception('Error fetching time slots.');
    }
  }

  // Delete a time slot for a child
  Future<void> deleteTimeSlot(String childId, int slotIndex) async {
    try {
      final response = await http.delete(Uri.parse('${Config.baseUrl}/api/time_management/$childId/$slotIndex'));

      if (response.statusCode == 200) {
        logger.i('Time slot deleted successfully');
      } else {
        logger.e('Failed to delete time slot. Error: ${response.body}');
        throw Exception('Error deleting time slot.');
      }
    } catch (e) {
      logger.e('Error deleting time slot: $e');
      rethrow;
    }
  }

   // Toggle is_allowed status for a time slot
  Future<void> toggleAllowedStatus(BuildContext context, String childId, int slotIndex, bool isAllowed) async {
    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/api/time_management/$childId/$slotIndex'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'is_allowed': isAllowed}),
      );

      if (response.statusCode == 200) {
        logger.i('Allowed status toggled successfully');
      } else {
        logger.e('Failed to toggle allowed status. Error: ${response.body}');
        throw Exception('Error toggling allowed status.');
      }
    } catch (e) {
      logger.e('Error toggling allowed status: $e');
      rethrow;
    }
  }


  // Add a new time slot
  void addNewTimeSlot(BuildContext context, String childId, List<Map<String, String>> timeSlots) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScreenTimeScheduleDialog(
          schedules: const [],
          childId: childId,
          onAddSchedule: (startTime, endTime) async {
            if (startTime != null && endTime != null) {
              DateTime newStartTime = convertTimeOfDayToDateTime(startTime);
              DateTime newEndTime = convertTimeOfDayToDateTime(endTime);

              // Check for time conflicts
              if (_isTimeConflicting(newStartTime, newEndTime, timeSlots)) {
                showErrorNotification(context, 'Time conflict detected. Please choose a different time range.');
                return;
              }

              Map<String, String> newTimeSlot = {
                'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                'is_allowed': 'true',
              };
              timeSlots.add(newTimeSlot);

              // Save the new slot
              try {
                await saveTimeManagement(childId, timeSlots);
              } catch (e) {
                logger.e('Error saving new time slot: $e');
              }
            }
          },
          onEditSchedule: (_, __, ___) {},
        );
      },
    );
  }

  // Edit an existing time slot with conflict detection
  void editTimeSlot(BuildContext context, String childId, List<Map<String, String>> timeSlots, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScreenTimeScheduleDialog(
          schedules: const [],
          childId: childId,
          onAddSchedule: (startTime, endTime) {},
          onEditSchedule: (editIndex, startTime, endTime) async {
            if (startTime != null && endTime != null) {
              DateTime newStartTime = convertTimeOfDayToDateTime(startTime);
              DateTime newEndTime = convertTimeOfDayToDateTime(endTime);

              // Check for time conflicts
              if (_isTimeConflicting(newStartTime, newEndTime, timeSlots, index)) {
                showErrorNotification(context, 'Time conflict detected. Please choose a different time range.');
                return;
              }

              // Only update the time slot at the given index, keeping others intact
              timeSlots[index] = {
                'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                'is_allowed': timeSlots[index]['is_allowed']!, // Preserve the existing is_allowed status
              };

              try {
                // Save the updated time slots back to the server
                await saveTimeManagement(childId, timeSlots);
                logger.i('Time slot edited successfully for child $childId');
              } catch (e) {
                logger.e('Error saving edited time slot: $e');
              }
            }
          },
        );
      },
    );
  }

  // Helper method to check for time conflicts
  bool _isTimeConflicting(DateTime newStartTime, DateTime newEndTime, List<Map<String, String>> timeSlots, [int? editingIndex]) {
    for (int i = 0; i < timeSlots.length; i++) {
      if (editingIndex != null && i == editingIndex) continue; // Skip the current editing slot

      DateTime existingStartTime = DateTime.parse('1970-01-01 ${timeSlots[i]['start_time']!}');
      DateTime existingEndTime = DateTime.parse('1970-01-01 ${timeSlots[i]['end_time']!}');

      if ((newStartTime.isBefore(existingEndTime) && newEndTime.isAfter(existingStartTime)) ||
          (newStartTime.isAtSameMomentAs(existingStartTime) || newEndTime.isAtSameMomentAs(existingEndTime))) {
        return true; // Conflict detected
      }
    }
    return false; // No conflict
  }
}

/*
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'config.dart'; // Ensure the correct import for Config if it's defined in another file

final Logger logger = Logger();

class TimeService {
  // Method to save time management for a child
  Future<void> saveTimeManagement(String childId, List<Map<String, String>> timeSlots) async {
    try {
      // Log the time slots to be sent to the backend
      logger.i('Saving time management for child: $childId, Time slots: $timeSlots');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/time_management/$childId'),  // Ensure the correct API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'time_slots': timeSlots,  // Send time slots to backend
        }),
      );

      if (response.statusCode == 200) {
        logger.i('Time management data saved successfully');
      } else {
        logger.e('Failed to save time management data. Error: ${response.body}');
        throw Exception('Error saving time management data.');
      }
    } catch (e) {
      logger.e('Error saving time management data: $e');
      rethrow;  // Ensure the error is thrown so catchError can handle it
    }
  }

  // Method to fetch time slots for a child
  Future<List<Map<String, dynamic>>> fetchTimeSlots(String childId) async {
  try {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/time_management/$childId'),
    );

    if (response.statusCode == 200) {
      // Decode the response body
      final List<dynamic> timeSlots = jsonDecode(response.body);
      
      // Ensure timeSlots is parsed correctly as a List of Maps
      List<Map<String, dynamic>> parsedTimeSlots = timeSlots.map((slot) {
        return Map<String, dynamic>.from(slot);
      }).toList();

      return parsedTimeSlots;
    } else {
      throw Exception('Error fetching time slots.');
    }
  } catch (error) {
    print('Error fetching time slots: $error');
    throw Exception('Error fetching time slots.');
  }
}


  // Method to delete a time slot for a child
  Future<void> deleteTimeSlot(String childId, int slotIndex) async {
    try {
      final response = await http.delete(Uri.parse('${Config.baseUrl}/api/time_management/$childId/$slotIndex'));

      if (response.statusCode == 200) {
        logger.i('Time slot deleted successfully');
      } else {
        logger.e('Failed to delete time slot. Error: ${response.body}');
        throw Exception('Error deleting time slot.');
      }
    } catch (e) {
      logger.e('Error deleting time slot: $e');
      rethrow;
    }
  }

  // Method to toggle is_allowed status for a time slot
  Future<void> toggleAllowedStatus(String childId, int slotIndex, bool isAllowed) async {
    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/api/time_management/$childId/$slotIndex'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'is_allowed': isAllowed}),
      );

      if (response.statusCode == 200) {
        logger.i('Allowed status toggled successfully');
      } else {
        logger.e('Failed to toggle allowed status. Error: ${response.body}');
        throw Exception('Error toggling allowed status.');
      }
    } catch (e) {
      logger.e('Error toggling allowed status: $e');
      rethrow;
    }
  }
}*/