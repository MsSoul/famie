//filename:service/api_service.dart (for parent login and  registration )
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'config.dart'; // Import the config file

class ApiService {
  final Logger logger = Logger();
  final Duration timeoutDuration = const Duration(seconds: 20); // Timeout for all requests

  // Sign up function
  Future<bool> signUp(String email, String username, String password) async {
    if (!_isValidEmail(email)) {
      logger.e('Invalid email format');
      throw Exception('Invalid email format');
    }
    if (!_isValidUsername(username)) {
      logger.e('Invalid username');
      throw Exception('Invalid username');
    }
    if (!_isValidPassword(password)) {
      logger.e('Invalid password');
      throw Exception('Invalid password');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'username': username,
          'password': password,
          'confirmPassword': password,
        }),
      ).timeout(timeoutDuration);

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return true;
      } else {
        logger.e('Failed to sign up: ${response.body}');
        return false;
      }
    } on SocketException {
      logger.e('No internet connection');
      throw Exception('No internet connection. Please try again.');
    } on TimeoutException {
      logger.e('Sign up request timed out');
      throw Exception('Request timed out. Please try again.');
    } catch (e, stackTrace) {
      logger.e('Exception during sign up: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Login function
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(timeoutDuration); // Timeout duration

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('parentId')) {
          return {'success': true, 'parentId': data['parentId']};
        } else {
          logger.e('Login failed: Missing parentId in response');
          return {'success': false, 'message': 'Login failed: No parentId returned'};
        }
      } else {
        logger.e('Login failed: ${response.body}');
        return {'success': false, 'message': 'Login failed. Please check your credentials.'};
      }
    } on SocketException {
      logger.e('No internet connection');
      return {'success': false, 'message': 'No internet connection'};
    } on TimeoutException {
      logger.e('Login request timed out');
      return {'success': false, 'message': 'Request timed out'};
    } catch (e, stackTrace) {
      logger.e('Exception during login: $e', error: e, stackTrace: stackTrace);
      return {'success': false, 'message': 'An error occurred'};
    }
  }

// Add the reset password function
Future<bool> resetPassword(String email) async {
  if (!_isValidEmail(email)) {
    logger.e('Invalid email format');
    throw Exception('Invalid email format');
  }

  try {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    ).timeout(timeoutDuration);

    logger.d('Response status: ${response.statusCode}');
    logger.d('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if the response body contains a success message
      if (data['message'] == 'Password reset link sent') {
        logger.i('Reset password link sent successfully to $email');
        return true;
      } else {
        logger.e('Failed to send reset password link: ${data['message']}');
        return false;
      }
    } else {
      logger.e('Failed to send reset password link: ${response.body}');
      return false;
    }
  } on SocketException {
    logger.e('No internet connection');
    throw Exception('No internet connection. Please try again.');
  } on TimeoutException {
    logger.e('Reset password request timed out');
    throw Exception('Request timed out. Please try again.');
  } catch (e, stackTrace) {
    logger.e('Exception during reset password: $e', error: e, stackTrace: stackTrace);
    return false;
  }
}

  // Email validation
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  // Username validation
  bool _isValidUsername(String username) {
    return username.isNotEmpty;
  }

  // Password validation
  bool _isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }
}
