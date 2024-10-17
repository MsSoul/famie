//fiilename:services/time_service.dart (api for time managemnt)
// filename: services/time_service.dart (API for time management)
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
Future<List<Map<String, String>>> fetchTimeSlots(String childId) async {
  try {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/time_management/$childId'));

    if (response.statusCode == 200) {
      final List<dynamic> timeSlots = jsonDecode(response.body);

      // Map each dynamic slot to a Map<String, String>, handling non-string values
      return timeSlots.map<Map<String, String>>((slot) {
        return (slot as Map<String, dynamic>).map<String, String>((key, value) {
          // Convert bool and other non-string values to strings
          if (value is bool) {
            return MapEntry(key, value.toString()); // Convert bool to 'true'/'false'
          } else if (value is int || value is double) {
            return MapEntry(key, value.toString()); // Convert numbers to string
          } else if (value is String) {
            return MapEntry(key, value); // Keep string as is
          } else {
            return MapEntry(key, value.toString()); // Fallback for any other types
          }
        });
      }).toList();
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
  
void addNewTimeSlot(BuildContext context, String childId, List<Map<String, String>> timeSlots) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ScreenTimeScheduleDialog(
        schedules: const [], // Empty schedule list for the dialog initially
        childId: childId,
        onAddSchedule: (TimeOfDay? startTime, TimeOfDay? endTime) {
          if (startTime != null && endTime != null) {
            DateTime newStartTime = convertTimeOfDayToDateTime(startTime);
            DateTime newEndTime = convertTimeOfDayToDateTime(endTime);

            // Check for time conflicts
            if (_isTimeConflicting(newStartTime, newEndTime, timeSlots)) {
              showErrorNotification(context, 'Time conflict detected. Please choose a different time range.');
              return;
            }

            // Define allowedHours here (hardcoded for now, you can modify it to get it dynamically)
            int allowedHours = 1; // Example: 1 hour

            // Convert allowedHours to seconds
            int allowedTimeInSeconds = (allowedHours * 3600).toInt();  // Calculate allowed time in seconds

            // Create a new time slot object
            Map<String, String> newTimeSlot = {
              'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
              'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
              'is_allowed': 'true',
              'allowed_time': allowedTimeInSeconds.toString(),  // Store allowed time in seconds
            };

            // Check for duplicate time slots before adding
            if (_isDuplicateTimeSlot(newTimeSlot, timeSlots)) {
              showErrorNotification(context, 'Duplicate time slot detected. Please choose a different time.');
              return;
            }

            // Add only the new time slot without duplicating the existing ones
            List<Map<String, String>> updatedTimeSlots = List.from(timeSlots);
            updatedTimeSlots.add(newTimeSlot);

            // Update the state synchronously
            timeSlots.clear();
            timeSlots.addAll(updatedTimeSlots);

            // Notify the user of success
            addTimeSuccessPrompt(context, onPromptClosed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Close the schedule dialog
            });
          }
        },
        onEditSchedule: (_, __, ___) {},
      );
    },
  );
}


  // Helper method to check for duplicate time slots
  bool _isDuplicateTimeSlot(Map<String, String> newSlot, List<Map<String, String>> existingSlots) {
    for (var slot in existingSlots) {
      if (slot['start_time'] == newSlot['start_time'] && slot['end_time'] == newSlot['end_time']) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicate
  }

  // Update a time slot with a PUT request
  Future<void> updateTimeSlot(String childId, int slotIndex, TimeOfDay startTime, TimeOfDay endTime) async {
    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/time_management/$childId/$slotIndex'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        }),
      );

      if (response.statusCode == 200) {
        logger.i('Time slot updated successfully');
      } else {
        logger.e('Failed to update time slot. Error: ${response.body}');
        throw Exception('Error updating time slot.');
      }
    } catch (e) {
      logger.e('Error updating time slot: $e');
      rethrow;
    }
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
//fiilename:services/time_service.dart 
//fiilename:services/time_service.dart (working nani with adding new time slot)
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
      body: jsonEncode({
        'is_allowed': isAllowed.toString(), // Ensure 'true' or 'false' is sent as a string
      }),
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

            // Create a new time slot and append it to the list
            Map<String, String> newTimeSlot = {
              'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
              'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
              'is_allowed': 'true',
            };

            // Append the new slot to the list, rather than replacing an existing one
            timeSlots.add(newTimeSlot);

            // Save the updated time slots to the backend
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
  Future<void> updateTimeSlot(String childId, int slotIndex, TimeOfDay startTime, TimeOfDay endTime, String isAllowed) async {
  try {
    // Ensure isAllowed is valid
    if (isAllowed == null || isAllowed.isEmpty) {
      isAllowed = 'false';  // Default it to 'false' or 'true' based on your logic
    }

    final response = await http.patch(
      Uri.parse('${Config.baseUrl}/api/time_management/$childId/$slotIndex'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        'is_allowed': isAllowed,  // Pass the valid value of is_allowed
      }),
    );

    if (response.statusCode == 200) {
      logger.i('Time slot updated successfully');
    } else {
      logger.e('Failed to update time slot. Error: ${response.body}');
      throw Exception('Error updating time slot.');
    }
  } catch (e) {
    logger.e('Error updating time slot: $e');
    rethrow;
  }
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
} */
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