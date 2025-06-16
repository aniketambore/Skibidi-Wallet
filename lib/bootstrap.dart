import 'dart:async';
import 'package:bitwit_shit/bloc/account/onboarding_preferences.dart';
import 'package:bitwit_shit/bloc/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:bitwit_shit/services/hydrated_bloc_storage.dart';
import 'package:bitwit_shit/services/breez_logger.dart';
import 'package:bitwit_shit/services/injector.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as liquid_sdk;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'bootstrap_error_page.dart';

final Logger _logger = Logger('Bootstrap');

typedef AppBuilder =
    Widget Function(
      ServiceInjector serviceInjector,
      SdkConnectivityCubit sdkConnectivityCubit,
    );

Future<void> bootstrap(AppBuilder builder) async {
  // runZonedGuarded wrapper is required to log Dart errors.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // TODO: iOS Extension requirement

      // Initialize library
      await _initializeBreezSdkLiquid();
      final ServiceInjector injector = ServiceInjector();
      final BreezLogger breezLogger = injector.breezLogger;
      breezLogger.registerBreezSdkLiquidLogs(injector.breezSdkLiquid);

      // TODO: Setup Date Utils

      await HydratedBlocStorage().initialize();

      final SdkConnectivityCubit sdkConnectivityCubit = SdkConnectivityCubit(
        breezSdkLiquid: injector.breezSdkLiquid,
        credentialsManager: injector.credentialsManager,
      );
      final bool isOnboardingComplete =
          await OnboardingPreferences.isOnboardingComplete();
      if (isOnboardingComplete) {
        _logger.info('Reconnect if secure storage has mnemonic.');
        final String? mnemonic =
            await injector.credentialsManager.restoreMnemonic();
        if (mnemonic != null) {
          await sdkConnectivityCubit.reconnect(mnemonic: mnemonic);
        }
      }
      runApp(builder(injector, sdkConnectivityCubit));
    },
    (Object error, StackTrace stackTrace) async {
      if (error is! FlutterErrorDetails) {
        _logger.severe('FlutterError: $error', error, stackTrace);
      }
    },
  );
}

Future<void> _initializeBreezSdkLiquid() async {
  try {
    await liquid_sdk.initialize();
  } catch (error, stackTrace) {
    _logger.severe(
      'Failed to initialize Breez SDK - Liquid: $error',
      error,
      stackTrace,
    );
    runApp(BootstrapErrorPage(error: error, stackTrace: stackTrace));
  }
}
