import 'package:bitwit_shit/bloc/payment_limits/payment_limits_cubit.dart';
import 'package:bitwit_shit/bloc/payments/payments_cubit.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_cubit.dart';
import 'package:bitwit_shit/bloc/account/account_cubit.dart';
import 'package:bitwit_shit/routes/send_payment/widgets/ln_payment_amount.dart';
import 'package:bitwit_shit/routes/send_payment/widgets/ln_payment_fee.dart';
import 'package:bitwit_shit/routes/send_payment/widgets/lnurl_payment_description.dart';
import 'package:bitwit_shit/routes/send_payment/widgets/lnurl_payment_header.dart';
import 'package:bitwit_shit/routes/send_payment/widgets/payment_processing_sheet.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:bitwit_shit/widgets/centered_loader.dart';
import 'package:bitwit_shit/widgets/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('LnPaymentPage');

class LnPaymentPage extends StatefulWidget {
  const LnPaymentPage({super.key, required this.lnInvoice});
  final LNInvoice lnInvoice;

  @override
  State<LnPaymentPage> createState() => _LnPaymentPageState();
}

class _LnPaymentPageState extends State<LnPaymentPage> {
  bool _isLoading = true;
  bool _isCalculatingFees = false;
  String errorMessage = '';
  LightningPaymentLimitsResponse? _lightningLimits;

  int? amountSat;
  PrepareSendResponse? _prepareResponse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BigInt? amountMsat = widget.lnInvoice.amountMsat;
      if ((amountMsat == null || amountMsat == BigInt.zero) &&
          context.mounted) {
        Navigator.pop(context);
        showFlushbar(
          context,
          message: 'Zero-amount lightning payments are not supported.',
        );
        return;
      }

      setState(() {
        amountSat = amountMsat!.toInt() ~/ 1000;
      });
      await _fetchLightningLimits();
    });
  }

  Future<void> _fetchLightningLimits() async {
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });
    final PaymentLimitsCubit paymentLimitsCubit =
        context.read<PaymentLimitsCubit>();
    try {
      final LightningPaymentLimitsResponse? response =
          await paymentLimitsCubit.fetchLightningLimits();
      setState(() {
        _lightningLimits = response;
      });
      await _handleLightningPaymentLimitsResponse();
    } catch (error) {
      setState(() {
        errorMessage = ExceptionHandler.extractMessage(error);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLightningPaymentLimitsResponse() async {
    final String? errorMessage = validatePayment(
      amountSat: amountSat!,
      throwError: true,
    );
    if (errorMessage == null) {
      await _prepareSendPayment(amountSat!);
    }
  }

  Future<void> _prepareSendPayment(int amountSat) async {
    final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();
    try {
      setState(() {
        _isCalculatingFees = true;
        _prepareResponse = null;
        errorMessage = '';
      });

      final PayAmount payAmount = PayAmount_Bitcoin(
        receiverAmountSat: BigInt.from(amountSat),
      );

      final PrepareSendRequest req = PrepareSendRequest(
        destination: widget.lnInvoice.bolt11,
        amount: payAmount,
      );

      final PrepareSendResponse response = await paymentsCubit
          .prepareSendPayment(req: req);
      setState(() {
        _prepareResponse = response;
      });
    } catch (error) {
      setState(() {
        _prepareResponse = null;
        errorMessage = ExceptionHandler.extractMessage(error);
        _isLoading = false;
      });
      rethrow;
    } finally {
      setState(() {
        _isCalculatingFees = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6C0B3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC6C0B3),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child:
                _isLoading
                    ? const CenteredLoader()
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LnurlPaymentHeader(
                          payeeName: '',
                          totalAmount:
                              amountSat! +
                              (_prepareResponse?.feesSat?.toInt() ?? 0),
                          errorMessage: errorMessage,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFDF6E3), Color(0xFFD6CFC0)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              LnPaymentAmount(
                                amountSat: amountSat!,
                                hasError: errorMessage.isNotEmpty,
                              ),
                              if (_prepareResponse != null &&
                                  _prepareResponse!.feesSat?.toInt() != 0) ...[
                                const SizedBox(height: 16),
                                LnPaymentFee(
                                  isCalculatingFees: _isCalculatingFees,
                                  feesSat:
                                      errorMessage.isEmpty
                                          ? _prepareResponse?.feesSat?.toInt()
                                          : null,
                                ),
                              ],
                              if (widget.lnInvoice.description != null &&
                                  widget.lnInvoice.description!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                LnPaymentDescription(
                                  metadataText: widget.lnInvoice.description!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _lightningLimits == null
                            ? _buildSendButton(
                              buttonText: "Retry",
                              onPressed: () {
                                _fetchLightningLimits();
                              },
                            )
                            : _buildSendButton(
                              buttonText: "Confirm Send",
                              onPressed: () async {
                                try {
                                  final result =
                                      await showProcessingPaymentSheet(
                                        context,
                                        paymentFunc: () async {
                                          final PaymentsCubit paymentsCubit =
                                              context.read<PaymentsCubit>();
                                          return await paymentsCubit
                                              .sendPayment(_prepareResponse!);
                                        },
                                      );

                                  if (result is SendPaymentResponse) {
                                    _logger.info(
                                      'SendPaymentResponse result - payment status: ${result.payment.status}',
                                    );
                                  }

                                  // Only navigate to home after the processing sheet is closed
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/',
                                      (Route<dynamic> route) => false,
                                    );
                                    if (result is String) {
                                      showFlushbar(context, message: result);
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showFlushbar(
                                      context,
                                      message: ExceptionHandler.extractMessage(
                                        e,
                                      ),
                                    );
                                  }
                                }
                              },
                              enabled:
                                  _prepareResponse != null &&
                                  errorMessage.isEmpty,
                            ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton({
    required String buttonText,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Material(
      color: AppTheme.accentPink, // Use theme pink
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: AppTheme.accentPink.withOpacity(0.3),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? validatePayment({required int amountSat, bool throwError = false}) {
    String? message;
    if (_lightningLimits == null) {
      message = 'Failed to retrieve payment limits. Please try again later.';
    }
    final int effectiveMinSat = _lightningLimits!.send.minSat.toInt();
    final int effectiveMaxSat = _lightningLimits!.send.maxSat.toInt();
    if (amountSat > effectiveMaxSat) {
      message =
          throwError
              ? 'Payment exceeds the limit {$effectiveMaxSat} SAT.'
              : 'Exceeds maximum sendable amount: {$effectiveMaxSat} SAT.';
    } else if (amountSat < effectiveMinSat) {
      message =
          throwError
              ? 'Payment is below the limit ({$effectiveMinSat} SAT).'
              : 'Below minimum accepted amount: {$effectiveMinSat} SAT.';
    }

    // Calculate total amount including fees
    final int totalAmount =
        amountSat + (_prepareResponse?.feesSat?.toInt() ?? 0);

    // Get locked balance from time capsules
    final lockedBalance =
        context
            .read<TimeCapsuleCubit>()
            .state
            .capsules
            .where((capsule) => !capsule.isUnlocked)
            .fold<BigInt>(
              BigInt.zero,
              (sum, capsule) => sum + capsule.amountSat,
            )
            .toInt();

    // Get total wallet balance
    final totalBalance =
        context.read<AccountCubit>().state.walletInfo?.balanceSat.toInt() ?? 0;

    // Calculate spendable balance
    final spendableBalance = totalBalance - lockedBalance;

    if (totalAmount > spendableBalance) {
      message =
          throwError
              ? 'Insufficient spendable balance. You have $spendableBalance sats available ($lockedBalance sats are locked in time capsules).'
              : 'Insufficient spendable balance. You have $spendableBalance sats available ($lockedBalance sats are locked in time capsules).';
    }

    setState(() {
      errorMessage = message ?? '';
    });
    if (message != null && throwError) {
      throw message;
    }
    return message;
  }
}
