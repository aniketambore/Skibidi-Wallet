import 'package:bitwit_shit/models/bug_report_behavior.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = Logger('BreezPreferences');

class BreezPreferences {
  // Preference Keys
  static const String _kBugReportBehavior = 'bug_report_behavior';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  // Bug Report Behavior
  Future<BugReportBehavior> get bugReportBehavior async {
    final SharedPreferences prefs = await _preferences;
    final int? value = prefs.getInt(_kBugReportBehavior);
    final BugReportBehavior behavior =
        BugReportBehavior.values[value ?? BugReportBehavior.prompt.index];

    _logger.info('Fetched BugReportBehavior: $behavior');
    return behavior;
  }

  Future<void> setBugReportBehavior(BugReportBehavior behavior) async {
    _logger.info('Setting BugReportBehavior: $behavior');
    final SharedPreferences prefs = await _preferences;
    await prefs.setInt(_kBugReportBehavior, behavior.index);
    // TODO: Add iOS App Group
  }
}
