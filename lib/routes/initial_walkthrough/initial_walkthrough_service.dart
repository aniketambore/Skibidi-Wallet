import 'package:bitwit_shit/bloc/account/account_cubit.dart';
import 'package:bitwit_shit/bloc/account/onboarding_preferences.dart';
import 'package:bitwit_shit/bloc/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:bitwit_shit/widgets/flushbar.dart';
import 'package:bitwit_shit/widgets/loader.dart';
import 'package:bitwit_shit/widgets/transparent_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:bitwit_shit/game/game.dart';

import 'mnemonics/enter_mnemonics_page.dart';

final _log = Logger('InitialWalkthroughService');

class InitialWalkthroughService {
  final BuildContext _context;
  late final SdkConnectivityCubit _connectionService;
  late final AccountCubit _accountCubit;

  /// Creates a service instance with required dependencies.
  InitialWalkthroughService(this._context) {
    _initializeDependencies();
  }

  /// Initialize dependencies using the provided context.
  void _initializeDependencies() {
    _connectionService = _context.read<SdkConnectivityCubit>();
    _accountCubit = _context.read<AccountCubit>();
    // _securityCubit = _context.read<SecurityCubit>();
  }

  /// Starts the wallet registration process after confirming with user.
  Future<void> registerWallet() async {
    _log.info("Let's Skibidi!");
    await _connect();
  }

  /// Starts the wallet restoration process using a mnemonic seed.
  Future<void> restoreWallet({
    List<String>? initialWords,
    String? errorMessage,
  }) async {
    _log.info('Restore wallet from mnemonic seed');
    final String? mnemonic = await _getMnemonic(
      initialWords: initialWords,
      errorMessage: errorMessage,
    );
    if (mnemonic == null) {
      return;
    }

    await _connect(mnemonic: mnemonic);
  }

  /// Gets the mnemonic seed from user input.
  Future<String?> _getMnemonic({
    List<String>? initialWords,
    String? errorMessage,
  }) async {
    _log.info('Get mnemonic, initialWords: ${initialWords?.length}');
    return Navigator.of(_context).push(
      MaterialPageRoute(
        builder:
            (context) => EnterMnemonicsPage(
              initialWords: initialWords ?? <String>[],
              errorMessage: errorMessage ?? '',
            ),
      ),
    );
  }

  /// Connects to the wallet using either a new wallet or restored mnemonic.
  Future<void> _connect({String? mnemonic}) async {
    final bool isRestoring = mnemonic != null;
    _log.info(isRestoring ? 'Restoring wallet' : 'Starting new wallet');

    final NavigatorState navigator = Navigator.of(_context);
    final TransparentPageRoute<void> loaderRoute = _showLoaderOverlay(
      navigator,
    );

    try {
      isRestoring
          ? await _restoreExistingWallet(mnemonic)
          : await _registerNewWallet();
      await _completeOnboarding();
      // navigator.pushReplacementNamed('/');
      isRestoring
          ? navigator.pushReplacementNamed('/')
          : navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const Game()),
          );
    } catch (error) {
      _handleConnectionError(error, mnemonic);
    } finally {
      _hideLoaderOverlay(navigator, loaderRoute);
    }
  }

  /// Restores an existing wallet using a mnemonic.
  Future<void> _restoreExistingWallet(String mnemonic) async {
    await _connectionService.restore(mnemonic: mnemonic);
    // await _securityCubit.completeMnemonicVerification();
    _accountCubit.setIsRestoring(true);
  }

  /// Registers a new wallet.
  Future<void> _registerNewWallet() async {
    await _connectionService.register();
  }

  /// Completes the onboarding process.
  Future<void> _completeOnboarding() async {
    await OnboardingPreferences.setOnboardingComplete(true);
  }

  /// Handles errors that occur during wallet connection.
  void _handleConnectionError(Object error, String? mnemonic) {
    final bool isRestoring = mnemonic != null;
    _log.info(
      "Failed to ${isRestoring ? "restore" : "register"} wallet.",
      error,
    );
    final String errorMessage = ExceptionHandler.extractMessage(error);
    if (isRestoring && _context.mounted) {
      restoreWallet(
        initialWords: mnemonic.split(' '),
        errorMessage: errorMessage,
      );
    }

    if (_context.mounted) {
      showFlushbar(_context, message: errorMessage);
    }
  }

  /* UI Helpers */

  /// Shows a loader overlay and returns the route for later removal.
  TransparentPageRoute<void> _showLoaderOverlay(NavigatorState navigator) {
    final TransparentPageRoute<void> route = createLoaderRoute(_context);
    navigator.push(route);
    return route;
  }

  /// Hides the loader overlay.
  void _hideLoaderOverlay(NavigatorState navigator, dynamic route) {
    navigator.removeRoute(route);
  }
}
