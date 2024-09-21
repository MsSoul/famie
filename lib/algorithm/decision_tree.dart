import 'package:logging/logging.dart';

class AppDecision {
  bool isAllowed;
  bool setTimeSchedule;

  // Create a logger instance
  final Logger _logger = Logger('AppDecision');

  AppDecision({required this.isAllowed, required this.setTimeSchedule});

  String makeDecision() {
    if (!isAllowed) {
      _logger.info('Decision: Block App');
      return 'Block App';
    } else {
      if (setTimeSchedule) {
        _logger.info('Decision: Set App Time Schedule');
        return 'Set App Time Schedule';
      } else {
        _logger.info('Decision: Allow App (No Time Schedule)');
        return 'Allow App (No Time Schedule)';
      }
    }
  }
}

void main() {
  // Set up logging
  Logger.root.level = Level.INFO; // Set the logging level
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Example scenarios
  AppDecision decision1 = AppDecision(isAllowed: false, setTimeSchedule: false);
  decision1.makeDecision(); // Logs: Decision: Block App

  AppDecision decision2 = AppDecision(isAllowed: true, setTimeSchedule: true);
  decision2.makeDecision(); // Logs: Decision: Set App Time Schedule

  AppDecision decision3 = AppDecision(isAllowed: true, setTimeSchedule: false);
  decision3.makeDecision(); // Logs: Decision: Allow App (No Time Schedule)
}
