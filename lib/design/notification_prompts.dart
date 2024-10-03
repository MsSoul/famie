//filename:design/notification_prompts.dart
import 'package:flutter/material.dart';
import '../main.dart';

// Success prompt for logging in
void showSuccessPrompt(BuildContext context) {
  // Get the theme's app bar color and text styles
  final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
  final textStyle = Theme.of(context).textTheme.bodyMedium;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: appBarColor!), // Use the app bar color for the border
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Congratulations!',
                style: textStyle?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Welcome to Famie, you successfully created an account. Proceed to login.',
                style: textStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // After closing the dialog, navigate to the login screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor, // Button color from theme's app bar
                  textStyle: textStyle, // Use theme's text style
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Notification prompt for deleting schedule
void showDeleteConfirmationPrompt(BuildContext context, Function onConfirmDelete) {
  final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!; // Get the app bar color from the theme
  final textStyle = Theme.of(context).textTheme.bodyMedium; // Use theme's text style

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Delete Schedule',
          style: textStyle?.copyWith(
            fontWeight: FontWeight.bold, // Make the title bold
            color: appBarColor, // Use the appBarColor for the title
          ),
        ),
        content: Text(
          'Are you sure you want to delete this schedule?',
          style: textStyle?.copyWith(fontSize: 18), // Larger font size for the content text
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
            child: Text(
              'Cancel',
              style: textStyle?.copyWith(
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
              style: textStyle?.copyWith(
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
  final textStyle = Theme.of(context).textTheme.bodyMedium; // Use theme's text style

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Error', style: textStyle),
        content: Text(message, style: textStyle),
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
  final appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!; // Get the app bar color from the theme
  final textStyle = Theme.of(context).textTheme.bodyMedium; // Use theme's text style

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Turn Off Schedule',
          style: textStyle?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to turn off this schedule?',
          style: textStyle,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without toggling
            },
            child: Text(
              'Cancel',
              style: textStyle?.copyWith(
                fontWeight: FontWeight.bold, // Make button text bold
                color: appBarColor, // Button text color
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onConfirmToggle(); // Execute the toggle function
              Navigator.of(context).pop(); // Close the dialog after confirmation
            },
            child: Text(
              'Turn Off',
              style: textStyle?.copyWith(
                fontWeight: FontWeight.bold, // Make button text bold
                color: appBarColor, // Button text color
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appBarColor, width: 2.0), // Add border with app bar color
          borderRadius: BorderRadius.circular(10.0), // Rounded corners for the dialog
        ),
      );
    },
  );
}

// Add Time success prompt with a callback after it is closed
void addTimeSuccessPrompt(BuildContext context, {required VoidCallback onPromptClosed}) {
  final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green;
  final textStyle = Theme.of(context).textTheme.bodyMedium; // Use theme's text style

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appBarColor, width: 2), // Border with appBarColor
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Time Schedule Added!',
          style: textStyle?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You have successfully added a new time schedule.',
          style: textStyle?.copyWith(color: Colors.black),
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

/*
import 'package:flutter/material.dart';
import '../main.dart';

// Success prompt for logging in
void showSuccessPrompt(BuildContext context) {
  // Get the theme's app bar color and text styles
  final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
  final textColor = Theme.of(context).textTheme.bodyMedium?.color;
  final textFontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: appBarColor!), // Use the app bar color for the border
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: textFontFamily, // Use the theme font family
                  color: textColor, // Use the theme text color
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Welcome to Famie, you successfully created an account. Proceed to login.',
                style: TextStyle(
                  fontFamily: textFontFamily, // Use the theme font family
                  color: textColor, // Use the theme text color
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // After closing the dialog, navigate to the login screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // Use the button style from the theme
                  backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                  foregroundColor: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                  textStyle: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}),
                  shape: Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({}),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                ),
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
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

*/