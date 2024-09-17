// filename:dashboard/dashboard_screen_time_limit.dart
/*import 'package:flutter/material.dart';
import '../child_profile/child_profile_manager.dart';
import 'package:logging/logging.dart';

class ScreenTimeLimit extends StatelessWidget {
  final String childId;

  const ScreenTimeLimit({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger('ScreenTimeLimit');
    final childProfileManager = ChildProfileManager();

    return FutureBuilder(
      future: childProfileManager.getScreenTimeLimits(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.severe('Error loading screen time limits: ${snapshot.error}');
          return Center(child: Text('Error loading screen time limits: ${snapshot.error}'));
        } else {
          final screenTimeLimits = snapshot.data ?? [];
          logger.info('Loaded screen time limits: $screenTimeLimits');

          if (screenTimeLimits.isEmpty) {
            return const Center(child: Text('No screen time limits available'));
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Screen Time Limit',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 10),
              for (var screenTimeLimit in screenTimeLimits)
                TimeCard(
                  title: screenTimeLimit['title'],
                  time: screenTimeLimit['time'],
                ),
            ],
          );
        }
      },
    );
  }
}

class TimeCard extends StatelessWidget {
  final String title;
  final String time;

  const TimeCard({
    super.key,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Text(
          time,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
*/