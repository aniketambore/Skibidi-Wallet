import 'package:bitwit_shit/services/breez_sdk_liquid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';

import 'account_state.dart';

final Logger _logger = Logger('AccountCubit');

class AccountCubit extends Cubit<AccountState>
    with HydratedMixin<AccountState> {
  final BreezSDKLiquid breezSdkLiquid;

  AccountCubit(this.breezSdkLiquid) : super(AccountState.initial()) {
    hydrate();

    _listenAccountChanges();
    _listenInitialSyncEvent();
  }

  void _listenAccountChanges() {
    _logger.info('Listening to account changes');
    breezSdkLiquid.getInfoResponseStream.distinct().listen((
      GetInfoResponse getInfoResponse,
    ) {
      final AccountState newState = state.copyWith(
        walletInfo: getInfoResponse.walletInfo,
        // blockchainInfo: getInfoResponse.blockchainInfo,
      );
      _logger.info('AccountState changed: $newState');
      emit(newState);
    });
  }

  void _listenInitialSyncEvent() {
    _logger.info('Listening to initial sync event.');
    breezSdkLiquid.didCompleteInitialSyncStream.listen((_) {
      _logger.info('Initial sync complete.');
      emit(state.copyWith(isRestoring: false, didCompleteInitialSync: true));
    });
  }

  @override
  AccountState? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      _logger.severe('No stored data found.');
      return null;
    }

    try {
      final AccountState result = AccountState.fromJson(json);
      _logger.fine('Successfully hydrated with $result');
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Error hydrating: $e');
      _logger.fine('Stack trace: $stackTrace');
      return AccountState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(AccountState state) {
    try {
      final Map<String, dynamic> result = state.toJson();
      _logger.fine('Serialized: $result');
      return result;
    } catch (e) {
      _logger.severe('Error serializing: $e');
      return null;
    }
  }

  @override
  String get storagePrefix =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'lVa' : 'AccountCubit';

  void setIsRestoring(bool isRestoring) {
    emit(state.copyWith(isRestoring: isRestoring));
  }

  void markShowcaseAsShown() {
    emit(state.copyWith(hasShownShowcase: true));
  }
}
