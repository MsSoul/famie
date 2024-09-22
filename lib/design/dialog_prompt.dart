//filename:design/dialog_prompts.dart (info for any parts of the apps)
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
