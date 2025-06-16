import 'dart:async';

import 'package:bitwit_shit/bloc/payments/payments_cubit.dart';
import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:bitwit_shit/widgets/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:logging/logging.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

final Logger _logger = Logger('PaymentProcessingSheet');

Future<dynamic> showProcessingPaymentSheet(
  BuildContext context, {
  required Future<dynamic> Function() paymentFunc,
}) async {
  await showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) => PaymentProcessingSheet(paymentFunc: paymentFunc),
  );
}

class PaymentProcessingSheet extends StatefulWidget {
  final Future<dynamic> Function() paymentFunc;

  const PaymentProcessingSheet({super.key, required this.paymentFunc});

  @override
  State<PaymentProcessingSheet> createState() => _PaymentProcessingSheetState();
}

class _PaymentProcessingSheetState extends State<PaymentProcessingSheet> {
  StreamSubscription<Payment>? _trackPaymentEventsSubscription;

  static const Duration timeoutDuration = Duration(seconds: 30);

  bool _showPaymentSent = false;

  @override
  void initState() {
    super.initState();
    _processPaymentAndClose();
  }

  @override
  void dispose() {
    _trackPaymentEventsSubscription?.cancel();
    super.dispose();
  }

  void _processPaymentAndClose() {
    widget
        .paymentFunc()
        .then(_handlePaymentSuccess)
        .catchError(_handlePaymentError);
  }

  void _handlePaymentSuccess(dynamic payResult) {
    if (!mounted) {
      return;
    }

    _handleLnPaymentResult(payResult);
  }

  void _handleLnPaymentResult(dynamic payResult) {
    if (payResult is SendPaymentResponse) {
      _trackLnPaymentEvents(payResult);
    } else {
      _onPaymentFailure();
    }
  }

  void _trackLnPaymentEvents(SendPaymentResponse payResult) {
    final Completer<bool> paymentCompleter = Completer<bool>();

    if (payResult.payment.details is PaymentDetails_Liquid) {
      _handleLiquidPayment(payResult, paymentCompleter);
    } else {
      _handleLnPayment(payResult, paymentCompleter);
    }

    // Wait at least 30 seconds for PaymentSucceeded event for LN payments, then show payment success sheet.
    final Future<void> timeoutFuture = Future<void>.delayed(timeoutDuration);
    Future.any(<Future<bool>>[
          paymentCompleter.future,
          timeoutFuture.then((_) => false),
        ])
        .then((bool paymentSucceeded) {
          if (!mounted) {
            return;
          }

          if (paymentSucceeded) {
            _showSuccessAndClose();
          } else {
            _closeSheetOnCompletion();
          }
        })
        .catchError((_) {
          if (mounted) {
            _onPaymentFailure();
          }
        });
  }

  void _handleLiquidPayment(
    SendPaymentResponse payResult,
    Completer<bool> paymentCompleter,
  ) {
    final PaymentState paymentStatus = payResult.payment.status;
    if (paymentStatus == PaymentState.pending ||
        paymentStatus == PaymentState.complete) {
      final String? paymentDestination = payResult.payment.destination;
      _logger.info(
        'Payment sent!${paymentDestination?.isNotEmpty == true ? ' Destination: $paymentDestination' : ''}',
      );
      paymentCompleter.complete(true);
    } else {
      _logger.warning('Payment failed! Status: $paymentStatus');
      paymentCompleter.complete(false);
    }
  }

  void _handleLnPayment(
    SendPaymentResponse payResult,
    Completer<bool> paymentCompleter,
  ) {
    final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();
    _trackPaymentEventsSubscription?.cancel();

    final String? expectedDestination = payResult.payment.destination;
    _logger.info(
      'Tracking outgoing payments for destination: $expectedDestination',
    );

    _trackPaymentEventsSubscription = paymentsCubit.trackPaymentEvents(
      paymentFilter:
          (Payment p) =>
              p.paymentType == PaymentType.send &&
              p.destination == expectedDestination &&
              p.status == PaymentState.complete,
      onData: (Payment p) {
        final String? paymentDestination = p.destination;
        _logger.info(
          'Outgoing payment detected!${paymentDestination?.isNotEmpty == true ? ' Destination: $paymentDestination' : ''}',
        );
        paymentCompleter.complete(true);
      },
      onError: (Object e) {
        _logger.warning('Failed to track outgoing payments.', e);
        paymentCompleter.complete(false);
      },
    );
  }

  void _showSuccessAndClose([dynamic payResult]) {
    if (!mounted) {
      return;
    }

    setState(() {
      _showPaymentSent = true;
    });

    // Launch confetti after the state update
    Future.microtask(() {
      Confetti.launch(
        context,
        options: const ConfettiOptions(particleCount: 100, spread: 70, y: 0.6),
      );
    });

    // Show success state for 2 seconds before closing
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (payResult == null) {
          _closeSheetOnCompletion();
        } else {
          Navigator.of(context).pop(payResult);
        }
      }
    });
  }

  void _closeSheetOnCompletion() {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();
  }

  void _handlePaymentError(Object err) {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(err);

    if (err is FrbException ||
        err is PaymentError_PaymentTimeout ||
        err is PaymentError_Generic) {
      _showErrorFlushbar(err);
    }
  }

  void _onPaymentFailure() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    showFlushbar(context, message: 'Failed to send payment');
  }

  void _showErrorFlushbar(Object err) {
    final String message = ExceptionHandler.extractMessage(err);
    showFlushbar(context, message: 'Failed to send payment: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC6C0B3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showPaymentSent)
                _buildLoadingContent()
              else
                _buildSuccessContent(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDF6E3), Color(0xFFD6CFC0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.charcoal,
              strokeWidth: 3,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Processing Payment',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please wait while we process your payment...',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF4B4B4B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: _closeSheetOnCompletion,
          child: Text(
            'Close',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.softBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDF6E3), Color(0xFFD6CFC0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: AppTheme.softBlue,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Payment Sent!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your payment has been successfully processed.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF4B4B4B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
