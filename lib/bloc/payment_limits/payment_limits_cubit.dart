import 'dart:async';

import 'package:bitwit_shit/services/breez_sdk_liquid.dart';
import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:logging/logging.dart';

import 'payment_limits_state.dart';

final Logger _logger = Logger('PaymentLimitsCubit');

class PaymentLimitsCubit extends Cubit<PaymentLimitsState> {
  final BreezSDKLiquid _breezSdkLiquid;

  PaymentLimitsCubit(this._breezSdkLiquid)
    : super(PaymentLimitsState.initial()) {
    _fetchPaymentLimits();
    _refreshPaymentLimitsOnResume();
  }

  StreamSubscription<FGBGType>? fgBgEventsStreamSubscription;

  void _refreshPaymentLimitsOnResume() {
    fgBgEventsStreamSubscription = FGBGEvents.instance.stream.listen((
      FGBGType event,
    ) {
      if (event == FGBGType.foreground) {
        _fetchPaymentLimits();
      }
    });
  }

  void _fetchPaymentLimits() {
    if (_breezSdkLiquid.instance != null) {
      _breezSdkLiquid.getInfoResponseStream.first
          .then((GetInfoResponse getInfoResponse) {
            fetchLightningLimits();
            // fetchOnchainLimits();
          })
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              emit(
                state.copyWith(
                  errorMessage: 'Fetching payment network limits timed out.',
                ),
              );
            },
          );
    } else {
      emit(state.copyWith(errorMessage: 'Breez SDK instance is not running'));
    }
  }

  @override
  Future<void> close() {
    fgBgEventsStreamSubscription?.cancel();
    return super.close();
  }

  Future<LightningPaymentLimitsResponse?> fetchLightningLimits() async {
    emit(state.copyWith(errorMessage: ''));
    if (_breezSdkLiquid.instance != null) {
      try {
        final LightningPaymentLimitsResponse lightningPaymentLimits =
            await _breezSdkLiquid.instance!.fetchLightningLimits();
        emit(
          state.copyWith(
            lightningPaymentLimits: lightningPaymentLimits,
            errorMessage: '',
          ),
        );
        return lightningPaymentLimits;
      } catch (e) {
        _logger.severe('fetchLightningLimits error', e);
        emit(state.copyWith(errorMessage: ExceptionHandler.extractMessage(e)));
        rethrow;
      }
    } else {
      emit(state.copyWith(errorMessage: 'Breez SDK instance is not running'));
      return null;
    }
  }

  @override
  void emit(PaymentLimitsState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}
