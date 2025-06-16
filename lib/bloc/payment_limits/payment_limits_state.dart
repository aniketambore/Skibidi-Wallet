import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

class PaymentLimitsState {
  final LightningPaymentLimitsResponse? lightningPaymentLimits;
  final String errorMessage;

  PaymentLimitsState({this.lightningPaymentLimits, this.errorMessage = ''});

  PaymentLimitsState.initial() : this();

  bool get hasError => errorMessage.isNotEmpty;

  PaymentLimitsState copyWith({
    LightningPaymentLimitsResponse? lightningPaymentLimits,
    OnchainPaymentLimitsResponse? onchainPaymentLimits,
    String? errorMessage,
  }) {
    return PaymentLimitsState(
      lightningPaymentLimits:
          lightningPaymentLimits ?? this.lightningPaymentLimits,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
