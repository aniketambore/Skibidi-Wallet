import 'package:bitwit_shit/bloc/payments/models/payment_error.dart';
import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('PaymentValidator');

/// Validates payment operations, checking limits and balances
class PaymentValidator {
  /// The function that performs the actual validation logic
  final void Function(int amount, bool outgoing) validatePayment;

  /// Creates a new PaymentValidator
  ///
  /// [validatePayment] The function that performs the validation
  /// [currency] The Bitcoin currency unit to use for formatting
  /// [texts] Translation strings for error messages
  const PaymentValidator({required this.validatePayment});

  /// Validates an incoming payment
  ///
  /// [amount] The payment amount in satoshis
  /// Returns an error message if validation fails, null otherwise
  String? validateIncoming(int amount) {
    return _validate(amount, false);
  }

  /// Validates an outgoing payment
  ///
  /// [amount] The payment amount in satoshis
  /// Returns an error message if validation fails, null otherwise
  String? validateOutgoing(int amount) {
    return _validate(amount, true);
  }

  /// Internal validation method
  ///
  /// [amount] The payment amount in satoshis
  /// [outgoing] Whether the payment is outgoing
  /// Returns an error message if validation fails, null otherwise
  String? _validate(int amount, bool outgoing) {
    _logger.info(
      'Validating ${outgoing ? "outgoing" : "incoming"} payment of $amount satoshis',
    );

    try {
      validatePayment(amount, outgoing);
      return null;
    } on Exception catch (e) {
      return _handleException(e);
    }
  }

  /// Handles validation exceptions and returns appropriate error messages
  ///
  /// [e] The exception that occurred during validation
  /// Returns a user-friendly error message
  String _handleException(Exception e) {
    _logger.warning('Payment validation failed', e);

    if (e is PaymentExceedsLimitError) {
      return 'Payment exceeds the limit (${e.limitSat.toInt()})';
    } else if (e is PaymentBelowLimitError) {
      return 'Payment is below the limit (${e.limitSat.toInt()})';
    } else if (e is InsufficientLocalBalanceError) {
      return 'Insufficient local balance';
    } else {
      return 'Validation error ${ExceptionHandler.extractMessage(e)}';
    }
  }
}
