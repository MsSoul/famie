//filename:famie/lib/algorithm/decision_tree.dart
import 'package:logging/logging.dart';

class AppDecision {
  bool isAllowed;
  bool setTimeSchedule;

  final Logger _logger = Logger('AppDecision');

  AppDecision({required this.isAllowed, required this.setTimeSchedule});

  String makeDecision() {
    if (!isAllowed) {
      // Toggle off: App is blocked
      _logger.info('Decision: Block App (Toggle OFF)');
      return 'Block App (Toggle OFF)';
    } else {
      if (setTimeSchedule) {
        _logger.info('Decision: Set App Time Schedule Prompt');
        return 'Set App Time Schedule Prompt'; 
      } else {
        _logger.info('Decision: Allow App (No Time Schedule, Toggle ON)');
        return 'Allow App (No Time Schedule, Toggle ON)';
      }
    }
  }
}

void main() {
  // Set up logging
  Logger.root.level = Level.INFO; // Set the logging level
  Logger.root.onRecord.listen((record) {
    // Log the message instead of printing
    Logger('Main').info('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Example scenarios
  AppDecision decision1 = AppDecision(isAllowed: false, setTimeSchedule: false);
  decision1.makeDecision(); // Logs: Block App (Toggle OFF)

  AppDecision decision2 = AppDecision(isAllowed: true, setTimeSchedule: true);
  decision2.makeDecision(); // Logs: Set App Time Schedule Prompt

  AppDecision decision3 = AppDecision(isAllowed: true, setTimeSchedule: false);
  decision3.makeDecision(); // Logs: Allow App (No Time Schedule, Toggle ON)
}

