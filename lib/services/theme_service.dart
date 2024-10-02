import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'config.dart'; // Import the config file

class ThemeService {
  final Logger logger = Logger();

  Future<ThemeData> fetchTheme(String adminId) async {
  try {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/theme/$adminId'));
    logger.d('Response status: ${response.statusCode}');
    logger.d('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final theme = json.decode(response.body);
      return _createThemeData(theme);
    } else if (response.statusCode == 404) {
      logger.e('Theme not found for adminId: $adminId');
      throw Exception('Theme not found for adminId: $adminId');
    } else {
      logger.e('Failed to fetch theme: ${response.body}');
      throw Exception('Failed to fetch theme');
    }
  } catch (e) {
    logger.e('Exception during fetch theme: $e');
    throw Exception('Failed to fetch theme: $e');
  }
}


  // Helper function to parse the color string into a Flutter Color object
  Color _parseColor(String color) {
    if (color.startsWith('#')) {
      color = color.substring(1);
    }
    return Color(int.parse('FF$color', radix: 16)); // Prepend 'FF' for full opacity
  }

  ThemeData _createThemeData(Map<String, dynamic> theme) {
    return ThemeData(
      primarySwatch: Colors.green, // Modify according to your theme needs
      fontFamily: theme['font_style'],
      scaffoldBackgroundColor: _parseColor(theme['background_color']),
      appBarTheme: AppBarTheme(
        backgroundColor: _parseColor(theme['app_bar_color']),
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _parseColor(theme['app_bar_color'])),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _parseColor(theme['app_bar_color'])),
        ),
        labelStyle: TextStyle(
          color: _parseColor(theme['app_bar_color']),
          fontFamily: theme['font_style'],
        ),
        hintStyle: TextStyle(
          color: _parseColor(theme['app_bar_color']),
          fontFamily: theme['font_style'],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(_parseColor(theme['button_color'])),
          foregroundColor: WidgetStateProperty.all(Colors.black),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: theme['font_style'],
            ),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: const TextStyle(color: Colors.black), // Set input text color to black
        bodyMedium: const TextStyle(color: Colors.black), // Set input text color to black
        labelLarge: TextStyle(color: _parseColor(theme['app_bar_color']), fontFamily: theme['font_style']),
        titleLarge: TextStyle(color: _parseColor(theme['app_bar_color']), fontFamily: theme['font_style']),
        titleMedium: TextStyle(color: _parseColor(theme['app_bar_color']), fontFamily: theme['font_style']),
      ),
    );
  }
}
