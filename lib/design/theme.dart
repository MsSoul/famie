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
    title: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: kToolbarHeight * 0.8, // Constrain the height
        ),
        child: Image.asset(
          'assets/image2.png',
          fit: BoxFit.contain,
        ),
      ),
    ),
    centerTitle: true,
    actions: isLoggedIn
        ? [
            IconButton(
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
            IconButton(
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
          ]
        : [],
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
