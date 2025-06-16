import 'dart:async';

import 'package:bitwit_shit/bloc/payments/payments_cubit.dart';
import 'package:bitwit_shit/dialogs/payment_received_dialog.dart';
import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:bitwit_shit/widgets/compact_qr_image.dart';
import 'package:bitwit_shit/widgets/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('InvoiceTracker');

void showInvoiceQRDialog(
  BuildContext context,
  String bolt11Invoice, {
  Widget? infoWidget,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => InvoiceTracker(
          bolt11Invoice: bolt11Invoice,
          onClose: () {
            Navigator.of(context).pop();
          },
          infoWidget: infoWidget,
        ),
  );
}

class InvoiceTracker extends StatefulWidget {
  final String bolt11Invoice;
  final VoidCallback onClose;
  final Widget? infoWidget;

  const InvoiceTracker({
    super.key,
    required this.bolt11Invoice,
    required this.onClose,
    this.infoWidget,
  });

  @override
  State<InvoiceTracker> createState() => _InvoiceTrackerState();
}

class _InvoiceTrackerState extends State<InvoiceTracker> {
  StreamSubscription<Payment>? _trackPaymentEventsSubscription;

  Future<void> _trackPaymentEvents({String? expectedDestination}) async {
    _logger.info(
      'Starting _trackPaymentEvents with expectedDestination: '
      '[33m$expectedDestination[0m',
    );
    final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();
    _trackPaymentEventsSubscription?.cancel();

    final bool Function(Payment)? paymentFilter = await _buildPaymentFilter(
      expectedDestination,
    );
    if (paymentFilter == null) {
      _logger.warning(
        'Skipping tracking payment events: paymentFilter is null.',
      );
      return;
    }

    _logger.info('Subscribing to payment events with filter.');
    _trackPaymentEventsSubscription = paymentsCubit.trackPaymentEvents(
      paymentFilter: paymentFilter,
      onData: _onTrackPaymentSucceed,
      onError: _onTrackPaymentError,
    );
  }

  Future<bool Function(Payment)?> _buildPaymentFilter(
    String? expectedDestination,
  ) async {
    if (expectedDestination != null) {
      _logger.info(
        'Building payment filter for destination: $expectedDestination',
      );
      return (Payment p) {
        final match =
            p.destination == expectedDestination &&
            (p.status == PaymentState.pending ||
                p.status == PaymentState.complete);
        _logger.info(
          'Filter check: payment.destination=${p.destination}, '
          'status=${p.status}, match=$match',
        );
        return match;
      };
    }

    _logger.warning(
      'Missing destination or LN Address in _buildPaymentFilter.',
    );
    return null;
  }

  void _onTrackPaymentSucceed(Payment p) {
    _logger.info(
      'Incoming payment detected! '
      'destination: [32m${p.destination}[0m, status: ${p.status}, payment: $p',
    );
    _onPaymentFinished(true);
  }

  void _onTrackPaymentError(Object e) {
    _logger.warning('Failed to track incoming payments.', e);
    if (mounted) {
      showFlushbar(context, message: ExceptionHandler.extractMessage(e));
    }
    _onPaymentFinished(false);
  }

  @override
  void initState() {
    super.initState();
    _logger.info(
      'InvoiceTracker initState: bolt11Invoice=${widget.bolt11Invoice}',
    );
    _trackPaymentEvents(expectedDestination: widget.bolt11Invoice);
  }

  @override
  void dispose() {
    _logger.info('InvoiceTracker dispose called.');
    if (_trackPaymentEventsSubscription != null) {
      _trackPaymentEventsSubscription?.cancel();
      _logger.info('Cancelled tracking payment events.');
    }
    super.dispose();
  }

  void _onPaymentFinished(bool isSuccess) {
    _logger.info('Payment finished: $isSuccess');
    if (!mounted) {
      _logger.warning('Widget not mounted in _onPaymentFinished.');
      return;
    }
    if (isSuccess) {
      Navigator.of(context).popUntil((route) => route.settings.name == '/');
      Future.microtask(() {
        showPaymentReceivedDialog(context);
      });
    } else {
      showFlushbar(context, title: '', message: 'Payment failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InvoiceQRDialog(
      bolt11Invoice: widget.bolt11Invoice,
      onClose: widget.onClose,
      infoWidget: widget.infoWidget,
    );
  }
}

class InvoiceQRDialog extends StatefulWidget {
  final String bolt11Invoice;
  final VoidCallback onClose;
  final Widget? infoWidget;

  const InvoiceQRDialog({
    super.key,
    required this.bolt11Invoice,
    required this.onClose,
    this.infoWidget,
  });

  @override
  State<InvoiceQRDialog> createState() => _InvoiceQRDialogState();
}

class _InvoiceQRDialogState extends State<InvoiceQRDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  void _onCopyTap() async {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    await Clipboard.setData(ClipboardData(text: widget.bolt11Invoice));
    setState(() {
      _isCopied = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF6E3), Color(0xFFD6CFC0)],
          ),
          borderRadius: BorderRadius.circular(38),
          border: Border.all(color: AppTheme.darkGray, width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              // Header
              Text(
                'LIGHTNING INVOICE',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.charcoal,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: AppTheme.primaryWhite.withOpacity(0.8),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan to pay',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B4B4B),
                ),
              ),
              const SizedBox(height: 30),

              // QR Code
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.charcoal.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFB8B1A2), width: 2),
                ),
                child: CompactQRImage(data: widget.bolt11Invoice, size: 200),
              ),
              const SizedBox(height: 24),
              // Copy Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ScaleTransition(
                  scale: _buttonScale,
                  child: GestureDetector(
                    onTap: _onCopyTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.charcoal, width: 2),
                        color:
                            _isCopied
                                ? AppTheme.softGreen
                                : AppTheme.accentPink,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isCopied ? Icons.check_circle : Icons.copy_rounded,
                            color: AppTheme.primaryWhite,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isCopied ? 'Copied!' : 'Copy Invoice',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryWhite,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.infoWidget != null) ...<Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: widget.infoWidget!,
                ),
              ],
              // Close Button
              TextButton(
                onPressed: widget.onClose,
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
