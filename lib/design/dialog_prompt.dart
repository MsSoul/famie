//filename:design/dialog_prompts.dart (info for any parts of the apps)
import 'package:flutter/material.dart';

class DialogPrompt extends StatelessWidget {
  const DialogPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, // Use the theme's font style
      color: Theme.of(context).textTheme.bodyMedium?.color, // Use the theme's text color
    );
    final ButtonStyle buttonStyle = TextButton.styleFrom(
      foregroundColor: appBarColor, // Use the app bar color for the OK button
      textStyle: const TextStyle(fontWeight: FontWeight.bold), // Bold text for the button
    );

    return AlertDialog(
      title: const Text(
        'Set App Time Schedule',
        style: TextStyle(fontWeight: FontWeight.bold), // Use theme's text style
      ),
      content: Text(
        'You can set the app time schedule based on the allowed screen time. '
        'For example, if the screen time is set between 7:00 AM to 9:00 AM or 3:00 PM to 5:00 PM, '
        'the app time must fall within these ranges.',
        style: textStyle, // Use theme's text style
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: appBarColor), // Border with app bar color
        borderRadius: BorderRadius.circular(10),
      ),
      actions: <Widget>[
        TextButton(
          style: buttonStyle, // Apply button style
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const DialogPrompt();
      },
    );
  }

  // New loading dialog for showing a message while fetching apps
  static Future<void> showLoading(BuildContext context) async {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, // Use the theme's font style
      color: Theme.of(context).textTheme.bodyMedium?.color, // Use the theme's text color
    );
    final ButtonStyle buttonStyle = TextButton.styleFrom(
      foregroundColor: appBarColor, // Use the app bar color for the OK button
      textStyle: const TextStyle(fontWeight: FontWeight.bold), // Bold text for the button
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Fetching Apps...',
            style: textStyle, // Use theme's text style
          ),
          content: Text(
            'This might take a while...\nThis area allows you to manage your child\'s apps, '
            'including blocking or allowing them and setting time schedules for each specific app based on the overall screen time schedule.',
            style: textStyle, // Use theme's text style
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: appBarColor), // Border with app bar color
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  // New prompt when attempting to toggle off system apps
  static Future<void> showSystemAppRestriction(BuildContext context) async {
    final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;
    final TextStyle textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, // Use the theme's font style
      color: Theme.of(context).textTheme.bodyMedium?.color, // Use the theme's text color
    );
    final ButtonStyle buttonStyle = TextButton.styleFrom(
      foregroundColor: appBarColor, // Use the app bar color for the OK button
      textStyle: const TextStyle(fontWeight: FontWeight.bold), // Bold text for the button
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'System Apps Restriction',
            style: textStyle.copyWith(fontWeight: FontWeight.bold), // Use theme's text style
            
          ),
          content: Text(
            'System Apps cannot be turned off, but they are considered locked. To allow your child to use them, you can set a time schedule. Please set a schedule instead',
            style: textStyle, // Use theme's text style
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: appBarColor), // Border with app bar color
            borderRadius: BorderRadius.circular(10),
          ),
          actions: <Widget>[
            TextButton(
              style: buttonStyle, // Apply button style
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  static Future<void> famkidInfoPrompt(
  BuildContext context,
  String parentId,
  void Function(String childName, String childAvatar) onChildRegistered, // Correct function type
) async {
  final Color appBarColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[200]!;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Welcome to Famie!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'As a parent, you can effectively manage your child\'s screen time. To add a child, please install the FamKid app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // The image with border
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: appBarColor, width: 2), // Match border color with AppBar color
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/famie_icon-removebg-preview.png', height: 100),
              ),
            ),
            // The "FAMKID" text outside the border
            const SizedBox(height: 10),
            Text(
              'FAMKID',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: appBarColor, // Apply AppBar color to the text
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'It will generate a QR code for you to scan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(color: appBarColor), // Match text color with AppBar color
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog only
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appBarColor, width: 2), // Match border color with AppBar color
          borderRadius: BorderRadius.circular(8.0),
        ),
      );
    },
  );
}
// New method for showing delete confirmation
static Future<void> showDeleteConfirmation(BuildContext context, String appName, VoidCallback onDelete) async {
  final Color actionColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[400]!; // Get action color from theme

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Delete Confirmation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete the schedule for $appName? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: actionColor, width: 2), // Add border color and width
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: actionColor), // Use action color for text
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(color: actionColor), // Use action color for text
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(); // Call the delete function
            },
          ),
        ],
      );
    },
  );
}

// Show an invalid schedule dialog
static Future<void> showInvalidSchedule(BuildContext context) async {
  final Color actionColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[400]!; // Get action color from theme

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Invalid Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'The schedule you are trying to set does not fit within the allowed time ranges. Please adjust the time.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: actionColor, width: 2), // Add border color and width
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(color: actionColor), // Use action color for text
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
 /// Method to show a success message
static Future<void> showSuccess(BuildContext context) async {
  // Get the action color from the theme
  final Color actionColor = Theme.of(context).appBarTheme.backgroundColor ?? Colors.green[400]!;

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Success',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Congratulations! The time schedule has been successfully added.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.green, width: 2),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(color: actionColor), // Set the color for the OK text
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Optionally, pop the previous screen if needed
            },
          ),
        ],
      );
    },
  );
}

}


/*ilisan kay e update ang design
import 'package:flutter/material.dart';

class DialogPrompt extends StatelessWidget {
  const DialogPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set App Time Schedule'),
      content: const Text(
          'You can set the app time schedule based on the allowed screen time. '
          'For example, if the screen time is set between 7:00 AM to 9:00 AM or 3:00 PM to 5:00 PM, '
          'the app time must fall within these ranges.'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const DialogPrompt();
      },
    );
  }

  // New loading dialog for showing a message while fetching apps
  static Future<void> showLoading(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Fetching Apps...'),
          content: Text(
              'This might take a while...\n This area allows you to manage your child\'s apps, including '
              'blocking or allowing them and setting time schedules for each specific app based on the overall screen time schedule.'),
        );
      },
    );
  }

  // New prompt when attempting to toggle off system apps
  static Future<void> showSystemAppRestriction(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('System Apps Restriction'),
          content: const Text(
            'Apps from System Apps cannot be turned off, but you can add a time schedule for them. '
            'Please set a schedule instead.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
*/
/*
import 'package:flutter/material.dart';

class DialogPrompt extends StatelessWidget {
  const DialogPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set App Time Schedule'),
      content: const Text(
          'You can set the app time schedule based on the allowed screen time. '
          'For example, if the screen time is set between 7:00 AM to 9:00 AM or 3:00 PM to 5:00 PM, '
          'the app time must fall within these ranges.'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const DialogPrompt();
      },
    );
  }

  // New loading dialog for showing a message while fetching apps
  static Future<void> showLoading(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Fetching Apps...'),
          content: Text(
              'This might take a while...\n This area allows you to manage your child\'s apps, including '
              'blocking or allowing them and setting time schedules for each specific app based on the overall screen time schedule.'),
        );
      },
    );
  }
}
*/

/*ilisan kay e update ang design
import 'package:flutter/material.dart';

class DialogPrompt extends StatelessWidget {
  const DialogPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set App Time Schedule'),
      content: const Text(
          'You can set the app time schedule based on the allowed screen time. '
          'For example, if the screen time is set between 7:00 AM to 9:00 AM or 3:00 PM to 5:00 PM, '
          'the app time must fall within these ranges.'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const DialogPrompt();
      },
    );
  }

  // New loading dialog for showing a message while fetching apps
  static Future<void> showLoading(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Fetching Apps...'),
          content: Text(
              'This might take a while...\n This area allows you to manage your child\'s apps, including '
              'blocking or allowing them and setting time schedules for each specific app based on the overall screen time schedule.'),
        );
      },
    );
  }

  // New prompt when attempting to toggle off system apps
  static Future<void> showSystemAppRestriction(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('System Apps Restriction'),
          content: const Text(
            'Apps from System Apps cannot be turned off, but you can add a time schedule for them. '
            'Please set a schedule instead.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
*/
/*
import 'package:flutter/material.dart';

class DialogPrompt extends StatelessWidget {
  const DialogPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set App Time Schedule'),
      content: const Text(
          'You can set the app time schedule based on the allowed screen time. '
          'For example, if the screen time is set between 7:00 AM to 9:00 AM or 3:00 PM to 5:00 PM, '
          'the app time must fall within these ranges.'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const DialogPrompt();
      },
    );
  }

  // New loading dialog for showing a message while fetching apps
  static Future<void> showLoading(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Fetching Apps...'),
          content: Text(
              'This might take a while...\n This area allows you to manage your child\'s apps, including '
              'blocking or allowing them and setting time schedules for each specific app based on the overall screen time schedule.'),
        );
      },
    );
  }
}
*/