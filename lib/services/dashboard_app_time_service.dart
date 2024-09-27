//filename: services/dashboard_app_time_service.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // WebSocket package
import 'package:http/http.dart' as http;
import 'config.dart'; // Your configuration file

class DashboardAppTimeService {
  final Logger logger = Logger(); // Initialize Logger
  WebSocketChannel? _channel; // WebSocket channel
  Function? onAppTimeUpdate; // Callback for app time updates
  Function? onRemainingAppTimeUpdate; // Callback for remaining app time updates

  // Open WebSocket connection
  void openWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${Config.baseUrl}'), // Replace with your actual WebSocket URL
    );
    logger.i('WebSocket connected to ${Config.baseUrl}');

    // Listen for WebSocket messages
    _channel!.stream.listen((message) {
      final data = jsonDecode(message);

      // Handle app time update
      if (data['type'] == 'app_time_update' && onAppTimeUpdate != null) {
        logger.i('Received app time update: ${data['data']}');
        onAppTimeUpdate!(data['data']);
      }

      // Handle remaining app time update
      if (data['type'] == 'remaining_app_time_update' && onRemainingAppTimeUpdate != null) {
        logger.i('Received remaining app time update: ${data['data']}');
        onRemainingAppTimeUpdate!(data['data']);
      }
    }, onError: (error) {
      logger.e('WebSocket error: $error');
    });
  }

  // Close WebSocket connection
  void closeWebSocket() {
    _channel?.sink.close();
  }

  // Fetch app time data from REST API
  Future<List<Map<String, dynamic>>?> fetchAppTime(String childId) async {
    final String url = '${Config.baseUrl}/api/app-time/get-app-time/$childId';
    logger.i('Fetching app time data from $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        logger.e('Failed to fetch app time data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Exception while fetching app time data: $e');
      return null;
    }
  }

  // Fetch remaining app time data from REST API
  Future<List<Map<String, dynamic>>?> fetchRemainingAppTime(String childId) async {
    final String url = '${Config.baseUrl}/api/app-time/get-remaining-app-time/$childId';
    logger.i('Fetching remaining app time data from $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        logger.e('Failed to fetch remaining app time data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Exception while fetching remaining app time data: $e');
      return null;
    }
  }
}
