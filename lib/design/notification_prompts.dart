//filename:design/notification_prompts.dart

import 'package:flutter/material.dart';
import '../main.dart';
//import 'settings/screentimelimit.dart';

void showSuccessPrompt(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white, // White background
        title: const Text('Congratulations!'),
        content: const Text('Welcome to Famie, you successfully created an account. Proceed to login.'),
        actionsAlignment: MainAxisAlignment.center, // Center the button
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[200], // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: const Text('Log In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
          ),
        ],
      );
    },
  );
}
/*
void showChildAddedPrompt(BuildContext context, int parentId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white, // White background
        title: const Text('Success!'),
        content: const Text('You successfully added a child. Please set the time limit.'),
        actionsAlignment: MainAxisAlignment.center, // Center the button
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ScreenTimeLimitScreen(parentId: parentId)),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[200], // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: const Text('Set Time Limit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
          ),
        ],
      );
    },
  );
}*/
