//filename:design/theme.dart
import 'package:flutter/material.dart';
import '../home.dart';
import '../main.dart';

// A function to dynamically create a theme using data from your database
ThemeData appThemeFromDatabase(Map<String, dynamic> themeData) {
  return ThemeData(
    primarySwatch: Colors.green,
    fontFamily: themeData['font_style'] ?? 'Georgia', // Custom or default font
    scaffoldBackgroundColor: Color(int.parse('0xff${themeData['background_color'] ?? 'FFFFFF'}')), // Custom background color with string interpolation

    appBarTheme: AppBarTheme(
      backgroundColor: Color(int.parse('0xff${themeData['app_bar_color'] ?? 'B1DC86'}')), // Custom app bar color with string interpolation
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(int.parse('0xff${themeData['app_bar_color'] ?? 'B1DC86'}'))), // App bar color for enabled border with string interpolation
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(int.parse('0xff${themeData['app_bar_color'] ?? 'B1DC86'}'))), // App bar color for focused border with string interpolation
      ),
      labelStyle: TextStyle(
        color: Color(int.parse('0xff${themeData['app_bar_color'] ?? 'B1DC86'}')), // App bar color for labels with string interpolation
        fontFamily: themeData['font_style'] ?? 'Georgia', // Custom font for labels
      ),
      hintStyle: TextStyle(
        color: Color(int.parse('0xff${themeData['app_bar_color'] ?? 'B1DC86'}')), // App bar color for hints with string interpolation
        fontFamily: themeData['font_style'] ?? 'Georgia', // Custom font for hints
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: Color(int.parse('0xff${themeData['text_color'] ?? '000000'}')), // Custom text color with string interpolation
        fontFamily: themeData['font_style'] ?? 'Georgia', // Custom font for body
      ),
      bodyMedium: TextStyle(
        color: Color(int.parse('0xff${themeData['text_color'] ?? '000000'}')), // Custom text color with string interpolation
        fontFamily: themeData['font_style'] ?? 'Georgia', // Custom font for medium body text
      ),
      titleLarge: TextStyle(
        color: Color(int.parse('0xff${themeData['app_bar_color'] ?? 'B1DC86'}')), // App bar color for titles with string interpolation
        fontFamily: themeData['font_style'] ?? 'Georgia', // Custom font for titles
      ),
      titleMedium: TextStyle(
        color: Color(int.parse('0xff${themeData['app_bar_color'] ?? 'B1DC86'}')), // App bar color for medium titles with string interpolation
        fontFamily: themeData['font_style'] ?? 'Georgia', // Custom font for medium titles
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Color(int.parse('0xff${themeData['button_color'] ?? 'B1DC86'}')), // Custom button color with string interpolation
        ),
        foregroundColor: WidgetStateProperty.all(Colors.black), // Custom button text color
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: themeData['font_style'] ?? 'Georgia', // Custom font for button text
          ),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Button shape
          ),
        ),
      ),
    ),
  );
}

// Edge insets for the app's margin
const EdgeInsets appMargin = EdgeInsets.all(40.0);

// Custom AppBar function
AppBar customAppBar(BuildContext context, String title, {bool isLoggedIn = false, String? parentId}) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    titleSpacing: 0.0, // Remove extra spacing
    automaticallyImplyLeading: false, // Prevent default back button from shifting the content
    title: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center, // Center the image
          child: Image.asset(
            'assets/image2.png', // Your logo asset path
            height: kToolbarHeight * 0.8, // Adjust the logo size
            fit: BoxFit.contain,
          ),
        ),
        if (isLoggedIn && parentId != null) // Display home icon only if logged in and parentId is available
          Align(
            alignment: Alignment.centerLeft, // Home icon to the left
            child: IconButton(
              icon: const Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                // Navigate back to HomeScreen with the parentId only if logged in
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(parentId: parentId)), // Use the actual parentId
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        if (isLoggedIn) // Show log out icon only when logged in
          Align(
            alignment: Alignment.centerRight, // Exit icon to the right
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              color: Colors.black,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
      ],
    ),
  );
}

/*
//filename:design/theme.dart
import 'package:flutter/material.dart';
import '../home.dart';
import '../main.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  fontFamily: 'Georgia',
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[200],
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    labelStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
    hintStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Colors.black),
    bodyMedium: const TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
    titleMedium: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.green[200]),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),
  ),
);

const EdgeInsets appMargin = EdgeInsets.all(40.0);

// Custom AppBar that only requires parentId when the user is logged in
AppBar customAppBar(BuildContext context, String title, {bool isLoggedIn = false, String? parentId}) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    titleSpacing: 0.0, // Remove extra spacing
    automaticallyImplyLeading: false, // Prevent default back button from shifting the content
    title: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center, // Center the image
          child: Image.asset(
            'assets/image2.png', // Your logo asset path
            height: kToolbarHeight * 0.8, // Adjust the logo size
            fit: BoxFit.contain,
          ),
        ),
        if (isLoggedIn && parentId != null) // Display home icon only if logged in and parentId is available
          Align(
            alignment: Alignment.centerLeft, // Home icon to the left
            child: IconButton(
              icon: const Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                // Navigate back to HomeScreen with the parentId only if logged in
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(parentId: parentId)), // Use the actual parentId
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        if (isLoggedIn) // Show log out icon only when logged in
          Align(
            alignment: Alignment.centerRight, // Exit icon to the right
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              color: Colors.black,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
      ],
    ),
  );
}*/
/*
//filename:design/theme.dart
import 'package:flutter/material.dart';
import '../home.dart';
import '../main.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  fontFamily: 'Georgia',
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[200],
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    labelStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
    hintStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Colors.black),
    bodyMedium: const TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
    titleMedium: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.green[200]),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),
  ),
);

const EdgeInsets appMargin = EdgeInsets.all(40.0);

// Custom AppBar that only requires parentId when the user is logged in
AppBar customAppBar(BuildContext context, String title, {bool isLoggedIn = false, String? parentId}) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    titleSpacing: 0.0, // Remove extra spacing
    automaticallyImplyLeading: false, // Prevent default back button from shifting the content
    title: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center, // Center the image
          child: Image.asset(
            'assets/image2.png', // Your logo asset path
            height: kToolbarHeight * 0.8, // Adjust the logo size
            fit: BoxFit.contain,
          ),
        ),
        if (isLoggedIn && parentId != null) // Display home icon only if logged in and parentId is available
          Align(
            alignment: Alignment.centerLeft, // Home icon to the left
            child: IconButton(
              icon: const Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                // Navigate back to HomeScreen with the parentId only if logged in
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(parentId: parentId)), // Use the actual parentId
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        if (isLoggedIn) // Show log out icon only when logged in
          Align(
            alignment: Alignment.centerRight, // Exit icon to the right
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              color: Colors.black,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
      ],
    ),
  );
}
*/

/*ang problema kay naa visible ang log out button
import 'package:flutter/material.dart';
import '../home.dart';
import '../main.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  fontFamily: 'Georgia',
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[200],
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    labelStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
    hintStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Colors.black),
    bodyMedium: const TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
    titleMedium: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.green[200]),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),
  ),
);

const EdgeInsets appMargin = EdgeInsets.all(40.0);

// Custom AppBar that only requires parentId when the user is logged in
AppBar customAppBar(BuildContext context, String title, {bool isLoggedIn = false, String? parentId}) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    titleSpacing: 0.0, // Remove extra spacing
    automaticallyImplyLeading: false, // Prevent default back button from shifting the content
    title: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center, // Center the image
          child: Image.asset(
            'assets/image2.png', // Your logo asset path
            height: kToolbarHeight * 0.8, // Adjust the logo size
            fit: BoxFit.contain,
          ),
        ),
        if (isLoggedIn && parentId != null) // Display action buttons only if logged in and parentId is available
          Align(
            alignment: Alignment.centerLeft, // Home icon to the left
            child: IconButton(
              icon: const Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                // Navigate back to HomeScreen with the parentId only if logged in
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(parentId: parentId)), // Use the actual parentId
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        Align(
          alignment: Alignment.centerRight, // Exit icon to the right
          child: IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: Colors.black,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
      ],
    ),
  );
}

*/
/*
import 'package:flutter/material.dart';
import '../home.dart';
import '../main.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  fontFamily: 'Georgia',
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[200],
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.green[200]!),
    ),
    labelStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
    hintStyle: TextStyle(
      color: Colors.green[200]!,
      fontFamily: 'Georgia',
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Colors.black),
    bodyMedium: const TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
    titleMedium: TextStyle(color: Colors.green[200], fontFamily: 'Georgia'),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.green[200]),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),
  ),
);

const EdgeInsets appMargin = EdgeInsets.all(40.0);

AppBar customAppBar(BuildContext context, String title, {bool isLoggedIn = false}) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    titleSpacing: 0.0, // Remove extra spacing
    automaticallyImplyLeading: false, // Prevent default back button from shifting the content
    title: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center, // Center the image
          child: Image.asset(
            'assets/image2.png', // Your logo asset path
            height: kToolbarHeight * 0.8, // Adjust the logo size
            fit: BoxFit.contain,
          ),
        ),
        if (isLoggedIn) // Display action buttons only if logged in
          Align(
            alignment: Alignment.centerLeft, // Home icon to the left
            child: IconButton(
              icon: const Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen(parentId: 'placeholder')),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        Align(
          alignment: Alignment.centerRight, // Exit icon to the right
          child: IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: Colors.black,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
      ],
    ),
  );
}

void main() {
  runApp(
    MaterialApp(
      theme: appTheme,
      home: const MyApp(),
    ),
  );
}
*/