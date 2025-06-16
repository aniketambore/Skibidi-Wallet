import 'package:bitwit_shit/services/breez_sdk_liquid.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as liquid_sdk;

final Logger _logger = Logger('BreezLogger');
final Logger _breezSdkLiquidLogger = Logger('BreezSdkLiquid');

class BreezLogger {
  BreezLogger() {
    Logger.root.level = Level.CONFIG;

    if (kDebugMode) {
      Logger.root.onRecord.listen((LogRecord record) {
        // Dart analyzer doesn't understand that here we are in debug mode so we have to use kDebugMode again
        if (kDebugMode) {
          print(_recordToString(record));
        }
      });
    }

    // TODO: Add session log file

    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);
      final String name = details.context?.name ?? 'FlutterError';
      final String exception = details.exceptionAsString();
      _logger.severe('$exception -- $name', details, details.stack);
    };
  }

  void registerBreezSdkLiquidLogs(BreezSDKLiquid breezSdkLiquid) {
    breezSdkLiquid.logStream.listen(
      (liquid_sdk.LogEntry e) =>
          _logBreezSdkLiquidEntries(e, _breezSdkLiquidLogger),
    );
  }

  void _logBreezSdkLiquidEntries(liquid_sdk.LogEntry log, Logger logger) {
    switch (log.level) {
      case 'ERROR':
        logger.severe(log.line);
        break;
      case 'WARN':
        logger.warning(log.line);
        break;
      case 'INFO':
        logger.info(log.line);
        break;
      case 'DEBUG':
        logger.config(log.line);
        break;
      case 'TRACE':
        logger.finest(log.line);
        break;
    }
  }

  String _recordToString(LogRecord record) =>
      '[${record.loggerName}] {${record.level.name}} (${_formatTime(record.time)}) : ${record.message}'
      "${record.error != null ? "\n${record.error}" : ""}"
      "${record.stackTrace != null ? "\n${record.stackTrace}" : ""}";

  String _formatTime(DateTime time) => time.toUtc().toIso8601String();
}
