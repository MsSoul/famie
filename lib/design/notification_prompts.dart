//filename:design/notification_prompts.dart
import 'package:flutter/material.dart';

// Success prompt for logging in
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

//notification prompt for deleting schedule
void showDeleteConfirmationPrompt(BuildContext context, Function onConfirmDelete) {
  final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!; // Get the app bar color from the theme

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Delete Schedule',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
            color: appBarColor, // Use the appBarColor for the title
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this schedule?',
          style: TextStyle(fontSize: 18), // Larger font size for the content text
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16, // Larger font size for the button
                fontWeight: FontWeight.bold, // Make the button text bold
                color: appBarColor, // Use the appBarColor for the Cancel button
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onConfirmDelete(); // Execute the delete function
              Navigator.of(context).pop(); // Close the dialog after deletion
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 16, // Larger font size for the button
                fontWeight: FontWeight.bold, // Make the button text bold
                color: appBarColor, // Use the appBarColor for the Delete button
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appBarColor, width: 2.0), // Add a border with appBarColor
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
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
// Add Time success prompt with a callback after it is closed
void addTimeSuccessPrompt(BuildContext context, {required VoidCallback onPromptClosed}) {
  // Get the app bar color from the current theme
  final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appBarColor, width: 2), // Border with appBarColor
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Time Schedule Added!',
          style: TextStyle(color: Colors.black),  // Title in black
        ),
        content: const Text(
          'You have successfully added a new time schedule.',
          style: TextStyle(color: Colors.black),  // Content text in black
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Close the prompt
              Navigator.of(context).pop();
              // Trigger the callback after the prompt is closed
              onPromptClosed();  // This will notify to refresh the display
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appBarColor,  // Match the appBar color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.white,  // Text color white to contrast with the app bar color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

