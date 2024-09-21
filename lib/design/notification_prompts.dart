//filename:design/notification_prompts.dart
import 'package:flutter/material.dart';

// Success prompt
void showSuccessPrompt(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Congratulations!'),
        content: const Text('Welcome to Famie, you successfully created an account. Proceed to login.'),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: const Text('Log In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
void showDeleteConfirmationPrompt(BuildContext context, Function onConfirmDelete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirmDelete(); // Execute the delete function
              Navigator.of(context).pop(); // Close the dialog after deletion
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

// Error notification
void showErrorNotification(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Error'),
        content: Text(message),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

// Toggle confirmation prompt
void showToggleConfirmationPrompt(BuildContext context, Function onConfirmToggle) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Turn Off Schedule'),
        content: const Text('Are you sure you want to turn off this schedule?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without toggling
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirmToggle(); // Execute the toggle function
              Navigator.of(context).pop(); // Close the dialog after confirmation
            },
            child: const Text('Turn Off'),
          ),
        ],
      );
    },
  );
}


/*

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
}*/