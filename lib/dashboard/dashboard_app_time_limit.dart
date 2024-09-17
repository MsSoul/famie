// filename:dashboard/dashboard_app_time_limit.dart
/*import 'package:flutter/material.dart';
import '../child_profile/child_profile_manager.dart';
import 'package:logging/logging.dart';

class AppTimeLimit extends StatelessWidget {
  final String childId;

  const AppTimeLimit({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger('AppTimeLimit');
    final childProfileManager = ChildProfileManager();

    return FutureBuilder(
      future: childProfileManager.getAppTimeLimits(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.severe('Error loading app time limits: ${snapshot.error}');
          return Center(child: Text('Error loading app time limits: ${snapshot.error}'));
        } else {
          final appTimeLimits = snapshot.data ?? [];
          logger.info('Loaded app time limits: $appTimeLimits');

          if (appTimeLimits.isEmpty) {
            return const Center(child: Text('No app time limits available'));
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'App Time Limit',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 10),
              for (var appTimeLimit in appTimeLimits)
                AppTimeLimitCard(
                  appName: appTimeLimit['appName'],
                  timeLeft: appTimeLimit['timeLeft'],
                  timeSpent: appTimeLimit['timeSpent'],
                ),
            ],
          );
        }
      },
    );
  }
}

class AppTimeLimitCard extends StatelessWidget {
  final String appName;
  final String timeLeft;
  final String timeSpent;

  const AppTimeLimitCard({
    super.key,
    required this.appName,
    required this.timeLeft,
    required this.timeSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/${appName.toLowerCase()}.png'),
              radius: 30.0,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Time Left: $timeLeft',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Time Spent: $timeSpent',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/