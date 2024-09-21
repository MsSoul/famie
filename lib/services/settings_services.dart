import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON encoding
import 'config.dart'; // Adjust this path if needed
import 'package:logging/logging.dart'; // Import the logging package

class SettingsService {
  // Initialize the Logger
  final Logger _logger = Logger('SettingsService');

  // Update app status function
  Future<void> updateAppStatus(String childId, String appName, bool isAllowed) async {
    const String url = '${Config.baseUrl}/api/settings/updateAppStatus';  // Use const for URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'childId': childId,
          'appName': appName,
          'isAllowed': isAllowed,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _logger.info(result['message']); // Log success message
      } else {
        final result = json.decode(response.body);
        _logger.severe('Error: ${result['message']}'); // Log error message
      }
    } catch (error) {
      _logger.severe('Error updating app status: $error'); // Log caught error
    }
  }
}
