import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('ExceptionHandler');

/// Utility class for extracting user-friendly error messages from exceptions
class ExceptionHandler {
  /// Private constructor to prevent instantiation
  ExceptionHandler._();

  /// Extracts a user-friendly message from an exception
  ///
  /// [exception] The exception to extract a message from
  /// [texts] Translations for localized error messages
  /// [defaultErrorMsg] Optional default error message if extraction fails
  /// Returns a user-friendly error message
  static String extractMessage(Object exception, {String? defaultErrorMsg}) {
    _logger.info('Extracting exception message: $exception');

    if (exception is AnyhowException) {
      if (exception.message.isNotEmpty) {
        String message = exception.message.replaceAll('\n', ' ').trim();
        message = _extractInnerErrorMessage(message)?.trim() ?? message;
        message = _localizedExceptionMessage(message);
        return message;
      }
    }

    if (exception is SdkError_Generic) {
      String message = exception.err.replaceAll('\n', ' ').trim();
      message = _extractInnerErrorMessage(message)?.trim() ?? message;
      message = _localizedExceptionMessage(message);
      return message;
    }

    if (exception is PaymentError) {
      return _getPaymentErrorMessage(exception);
    }

    return _extractInnerErrorMessage(exception.toString()) ??
        defaultErrorMsg ??
        exception.toString();
  }

  /// Gets a user-friendly message for PaymentError exceptions
  ///
  /// [error] The PaymentError to extract a message from
  /// [texts] Translations for localized error messages
  /// Returns a user-friendly error message
  static String _getPaymentErrorMessage(PaymentError error) {
    String message = error.toString();

    if (error is PaymentError_AlreadyClaimed) {
      message = 'The specified funds have already been claimed';
    } else if (error is PaymentError_AlreadyPaid) {
      message = 'The specified funds have already been sent';
    } else if (error is PaymentError_PaymentInProgress) {
      message = 'The payment is already in progress';
    } else if (error is PaymentError_AmountOutOfRange) {
      message = 'Amount is out of range';
    } else if (error is PaymentError_AmountMissing) {
      message = 'Amount is missing: ${error.err}';
    } else if (error is PaymentError_InvalidNetwork) {
      message = 'Invalid network: ${error.err}';
    } else if (error is PaymentError_Generic) {
      if (error.err.toLowerCase().contains('non-final') ||
          error.err.toLowerCase().contains('rpc error -26')) {
        message =
            'The transaction cannot be broadcast at this time. Please try again later.';
      }
      message = 'Payment error: ${error.err}';
    } else if (error is PaymentError_InvalidOrExpiredFees) {
      message = 'The provided fees have expired';
    } else if (error is PaymentError_InsufficientFunds) {
      message = 'Insufficient local balance';
    } else if (error is PaymentError_InvalidDescription) {
      message = 'Invalid description: ${error.err}';
    } else if (error is PaymentError_InvalidInvoice) {
      message = 'The specified invoice is not valid: ${error.err}';
    } else if (error is PaymentError_InvalidPreimage) {
      message = 'The generated preimage is not valid';
    } else if (error is PaymentError_PairsNotFound) {
      message = 'Boltz did not return any pairs from the request';
    } else if (error is PaymentError_PaymentTimeout) {
      message = 'The payment timed out';
    } else if (error is PaymentError_PersistError) {
      message = 'Could not store the swap details locally';
    } else if (error is PaymentError_SelfTransferNotSupported) {
      message = 'Sending payments to your own wallet is not supported';
    } else if (error is PaymentError_SendError) {
      message = error.err;
    } else if (error is PaymentError_SignerError) {
      message = 'Could not sign the transaction: ${error.err}';
    }

    return message;
  }

  /// Extracts inner error messages from exception strings
  ///
  /// [content] The exception string to parse
  /// Returns the inner error message or null if none is found
  static String? _extractInnerErrorMessage(String content) {
    _logger.info('Extracting inner error message: $content');

    final RegExp innerMessageRegex = RegExp(
      r'((?<=message: \\")(.*)(?=.*\\"))',
    );
    final RegExp messageRegex = RegExp(r'((?<=message: ")(.*)(?=.*"))');
    final RegExp causedByRegex = RegExp(r'((?<=Caused by: )(.*)(?=.*))');
    final RegExp reasonRegex = RegExp(r'((?<=FAILURE_REASON_)(.*)(?=.*))');

    return innerMessageRegex.stringMatch(content) ??
        messageRegex.stringMatch(content) ??
        causedByRegex.stringMatch(content) ??
        reasonRegex.stringMatch(content);
  }

  /// Maps error messages to localized strings
  ///
  /// [texts] Translations for localized error messages
  /// [originalMessage] The original error message
  /// Returns a localized error message
  static String _localizedExceptionMessage(
    // BreezTranslations texts,
    String originalMessage,
  ) {
    _logger.info('Localizing exception message: $originalMessage');

    // final String messageToLower = originalMessage.toLowerCase();

    // if (messageToLower.contains('transport error')) {
    //   return texts.generic_network_error;
    // } else if (messageToLower.contains('insufficient_balance')) {
    //   return texts.payment_error_insufficient_balance;
    // } else if (messageToLower.contains('incorrect_payment_details')) {
    //   return texts.payment_error_incorrect_payment_details;
    // } else if (messageToLower == 'error') {
    //   return texts.payment_error_unexpected_error;
    // } else if (messageToLower == 'no_route') {
    //   return texts.payment_error_no_route;
    // } else if (messageToLower == 'timeout') {
    //   return texts.payment_error_payment_timeout_exceeded;
    // } else if (messageToLower == 'none') {
    //   return texts.payment_error_none;
    // } else if (messageToLower.startsWith(
    //   "lsp doesn't support opening a new channel",
    // )) {
    //   return texts.lsp_error_cannot_open_channel;
    // } else if (messageToLower.contains('dns error') ||
    //     messageToLower.contains('os error 104')) {
    //   return texts.generic_network_error;
    // } else if (messageToLower.contains('mnemonic has an invalid checksum')) {
    //   return texts.enter_backup_phrase_error;
    // } else {
    //   return originalMessage;
    // }
    return originalMessage;
  }
}
