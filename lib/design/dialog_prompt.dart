//filename:design/dialog_prompts.dart (info for any parts of the apps)
// filename: design/dialog_prompts.dart (info for any parts of the apps)
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