import 'package:bitwit_shit/bloc/account/account_cubit.dart';
import 'package:bitwit_shit/bloc/account/account_state.dart';
import 'package:bitwit_shit/bloc/payment_limits/payment_limits_cubit.dart';
import 'package:bitwit_shit/bloc/payment_limits/payment_limits_state.dart';
import 'package:bitwit_shit/bloc/payments/payments_cubit.dart';
import 'package:bitwit_shit/dialogs/invoice_qr_dialog.dart';
import 'package:bitwit_shit/services/lnurl_service.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:bitwit_shit/utils/payment_validator.dart';
import 'package:bitwit_shit/widgets/centered_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'dart:math' show cos, sin;

import 'package:provider/provider.dart';

import 'widgets/payment_fees_message_box.dart';

final _log = Logger('ReceiveScreen');

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen>
    with TickerProviderStateMixin {
  String _amount = '';
  late AnimationController _feedbackController;
  late Animation<Offset> _feedbackAnimation;
  String _feedbackMessage = '';
  bool _isGenerating = false;
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  LightningPaymentLimitsResponse? _lightningPaymentLimits;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0.0),
    ).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticIn),
    );

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _gradientAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // Full rotation in radians
    ).animate(_gradientController);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    if (_isGenerating) return;
    if (_amount.length < 10) {
      // Limit to 10 digits
      setState(() {
        _amount += number;
        _feedbackMessage = '';
      });
    }
  }

  void _onBackspaceTap() {
    if (_isGenerating) return;
    if (_amount.isNotEmpty) {
      setState(() {
        _amount = _amount.substring(0, _amount.length - 1);
        _feedbackMessage = '';
      });
    }
  }

  void _onGenerateInvoice() async {
    if (_isGenerating || _amount.isEmpty) return;

    final int amount = int.parse(_amount);
    final String? validationError = validatePayment(
      amount,
      _lightningPaymentLimits!,
    );

    if (validationError != null) {
      setState(() {
        _feedbackMessage = validationError;
      });

      _feedbackController.forward(from: 0.0).then((_) {
        if (mounted) {
          _feedbackController.reverse();
        }
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _feedbackMessage = '';
    });

    await _createInvoice();
  }

  Future<void> _createInvoice() async {
    _log.info('Create invoice: amount=$_amount');
    try {
      final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();
      final BigInt payerAmountSat = BigInt.from(int.parse(_amount));
      final prepareReceiveResponse = await paymentsCubit.prepareReceivePayment(
        paymentMethod: PaymentMethod.bolt11Invoice,
        payerAmountSat: payerAmountSat,
      );
      final receivePaymentResponse = await paymentsCubit.receivePayment(
        prepareResponse: prepareReceiveResponse,
        description: 'Skibidi Wallet',
      );
      showInvoiceQRDialog(
        context,
        receivePaymentResponse.destination,
        infoWidget: PaymentFeesMessageBox(
          feesSat: prepareReceiveResponse.feesSat.toInt(),
        ),
      );
    } catch (e, stackTrace) {
      _log.info('Failed to create invoice: $e with stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _feedbackMessage = 'Failed to create invoice';
        });
        _feedbackController.forward(from: 0.0).then((_) {
          if (mounted) {
            _feedbackController.reverse();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentLimitsCubit, PaymentLimitsState>(
      builder: (context, state) {
        final hasError = state.hasError;
        final errorMessage = state.errorMessage;

        final LightningPaymentLimitsResponse? lightningPaymentLimits =
            state.lightningPaymentLimits;

        if (lightningPaymentLimits == null) {
          return const CenteredLoader();
        }

        _lightningPaymentLimits = lightningPaymentLimits;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 110, horizontal: 24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated gradient border
              AnimatedBuilder(
                animation: _gradientAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(38),
                      gradient: LinearGradient(
                        begin: Alignment(
                          cos(_gradientAnimation.value),
                          sin(_gradientAnimation.value),
                        ),
                        end: Alignment(
                          -cos(_gradientAnimation.value),
                          -sin(_gradientAnimation.value),
                        ),
                        colors: const [
                          Color(0xFFFDF6E3),
                          Color(0xFFD6CFC0),
                          Color(0xFFFDF6E3),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Main content container
              _buildAmountForm(hasError, errorMessage),
              // Card border highlight for extra 3D pop
              IgnorePointer(
                child: Container(
                  // width: cardWidth,
                  // height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Container _buildAmountForm(bool hasError, String errorMessage) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF6E3), Color(0xFFD6CFC0)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(-6, -6),
          ),
        ],
        border: Border.all(color: const Color(0xFFB8B1A2), width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    // Header
                    Text(
                      'RECEIVE SATS',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2A2A2A),
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter amount to receive',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B4B4B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Minimum 100 sats',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4B4B4B).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Amount Display
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFB8B1A2),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₿ ',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2A2A2A),
                            ),
                          ),
                          Text(
                            _amount.isEmpty ? '0' : _amount,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2A2A2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Feedback Message
                    if (_feedbackMessage.isNotEmpty || hasError)
                      SlideTransition(
                        position: _feedbackAnimation,
                        child: Text(
                          hasError
                              ? '$errorMessage. Please try again later.'
                              : _feedbackMessage,
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 30),
                    // Number Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        // physics: const NeverScrollableScrollPhysics(),
                        itemCount: 12, // 0-9, backspace, and generate
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio: 1.0,
                            ),
                        itemBuilder: (context, index) {
                          if (index == 9) {
                            // Backspace button
                            return _buildActionButton(
                              icon: Icons.backspace_rounded,
                              onTap: _onBackspaceTap,
                              color: const Color(0xFFB8B1A2),
                            );
                          } else if (index == 10) {
                            // Zero button
                            return _buildNumberButton('0');
                          } else if (index == 11) {
                            // Generate button
                            return _buildActionButton(
                              icon: Icons.bolt_rounded,
                              onTap: _onGenerateInvoice,
                              color: AppTheme.accentPink,
                              isGenerating: _isGenerating,
                            );
                          } else {
                            // Number buttons 1-9
                            return _buildNumberButton((index + 1).toString());
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => _onNumberTap(number),
        borderRadius: BorderRadius.circular(15),
        splashColor: const Color(0xFFB8B1A2).withOpacity(0.2),
        highlightColor: const Color(0xFFB8B1A2).withOpacity(0.1),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFB8B1A2).withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2A2A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isGenerating = false,
  }) {
    return Material(
      color: color.withOpacity(0.9),
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child:
              isGenerating
                  ? SizedBox(
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  String? validatePayment(
    int amount,
    LightningPaymentLimitsResponse lightningPaymentLimits,
  ) {
    return PaymentValidator(
      validatePayment:
          (int amount, bool outgoing) =>
              _validatePayment(amount, outgoing, lightningPaymentLimits),
    ).validateIncoming(amount);
  }

  void _validatePayment(
    int amount,
    bool outgoing,
    LightningPaymentLimitsResponse lightningPaymentLimits,
  ) {
    final AccountState accountState = context.read<AccountCubit>().state;
    final int balance = accountState.walletInfo!.balanceSat.toInt();
    final LnUrlService lnUrlService = Provider.of<LnUrlService>(
      context,
      listen: false,
    );
    return lnUrlService.validateLnUrlPayment(
      amount: BigInt.from(amount),
      outgoing: outgoing,
      lightningLimits: lightningPaymentLimits,
      balance: balance,
    );
  }
}
