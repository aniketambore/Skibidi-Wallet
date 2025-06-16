import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

class PaymentResult {
  final Payment? paymentInfo;
  final PaymentResultError? error;

  const PaymentResult({this.paymentInfo, this.error});

  @override
  String toString() {
    return 'PaymentResult{paymentInfo: $paymentInfo, error: $error}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentResult &&
          runtimeType == other.runtimeType &&
          paymentInfo == other.paymentInfo &&
          error == other.error;

  @override
  int get hashCode => paymentInfo.hashCode ^ error.hashCode;
}

class PaymentResultError {
  final String message;
  final String paymentHash;
  final String comment;

  const PaymentResultError({
    required this.message,
    required this.paymentHash,
    required this.comment,
  });

  factory PaymentResultError.fromException(
    String paymentHash,
    Object? error, {
    BuildContext? context,
  }) {
    // final BreezTranslations texts =
    //     context?.texts() ?? getSystemAppLocalizations();
    final String? displayMessage =
        error != null ? ExceptionHandler.extractMessage(error) : null;
    return PaymentResultError(
      message:
          displayMessage != null
              ? 'Failed to send payment: $displayMessage'
              : 'Failed to send payment',
      paymentHash: paymentHash,
      comment: error?.toString() ?? 'Unknown error',
    );
  }

  @override
  String toString() {
    return 'PaymentResultError{message: $message, paymentHash: $paymentHash, comment: $comment}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentResultError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          paymentHash == other.paymentHash &&
          comment == other.comment;

  @override
  int get hashCode =>
      message.hashCode ^ paymentHash.hashCode ^ comment.hashCode;
}
