import 'package:bitwit_shit/bloc/input/input_cubit.dart';
import 'package:bitwit_shit/bloc/input/input_printer.dart';
import 'package:bitwit_shit/routes/send_payment/ln_invoice_payment_page.dart';
import 'package:bitwit_shit/widgets/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' show cos, sin;
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard
import 'package:logging/logging.dart';

final Logger _logger = Logger('SendScreen');

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  String _invoice = ''; // Add this state variable

  // Feedback message and animation
  late AnimationController _feedbackController;
  late Animation<Offset> _feedbackAnimation;
  String _feedbackMessage = '';

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _gradientAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // Full rotation in radians
    ).animate(_gradientController);

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
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handlePaste() async {
    if (_isGenerating) return;

    try {
      final ClipboardData? clipboardData = await Clipboard.getData(
        Clipboard.kTextPlain,
      );
      if (clipboardData != null && clipboardData.text != null) {
        setState(() {
          _invoice = clipboardData.text!;
        });
      }
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Failed to paste from clipboard';
      });
      _feedbackController.forward(from: 0.0).then((_) {
        if (mounted) {
          _feedbackController.reverse();
        }
      });
    }
  }

  /// Opens the QR scanner and processes the result.
  Future<void> _handleScan() async {
    if (_isGenerating) return;

    // Navigate to QR scan page
    final String? barcode = await Navigator.pushNamed<String>(
      context,
      '/qr_scan',
    );

    // Handle the scan result
    if (!mounted) {
      return;
    }

    if (barcode == null || barcode.isEmpty) {
      showFlushbar(context, message: 'QR code wasn\'t detected.');
      return;
    }

    setState(() {
      _invoice = barcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 210, horizontal: 24),
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
          _buildSendForm(),
          // Card border highlight for extra 3D pop
          IgnorePointer(
            child: Container(
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
  }

  Container _buildSendForm() {
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
                      'SEND SATS',
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
                      'Enter payment details',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B4B4B),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Input Container
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
                          Expanded(
                            child: Text(
                              _invoice.isEmpty
                                  ? 'Enter payment details'
                                  : _invoice,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    _invoice.isEmpty
                                        ? const Color(
                                          0xFF4B4B4B,
                                        ).withOpacity(0.7)
                                        : const Color(0xFF4B4B4B),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_invoice.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _invoice = '';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB8B1A2,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: Color(0xFF4B4B4B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Feedback Message
                    if (_feedbackMessage.isNotEmpty)
                      SlideTransition(
                        position: _feedbackAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _feedbackMessage,
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.content_paste_rounded,
                              label: 'Paste',
                              onTap: _handlePaste,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.qr_code_scanner_rounded,
                              label: 'Scan',
                              onTap: _handleScan,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Send Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSendButton(),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: const Color(0xFFB8B1A2).withOpacity(0.2),
        highlightColor: const Color(0xFFB8B1A2).withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFB8B1A2).withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF2A2A2A), size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Material(
      color: AppTheme.accentPink, // Use theme pink
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: AppTheme.accentPink.withOpacity(0.3),
      child: InkWell(
        onTap: _onSendPressed,
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
              _isGenerating
                  ? SizedBox(
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Send',
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

  /// Validates the current input and updates error message if needed.
  Future<void> _onSendPressed() async {
    if (!mounted || _isGenerating) return;

    if (_invoice.isEmpty) {
      setState(() {
        _feedbackMessage = 'Please enter an invoice';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final InputCubit inputCubit = context.read<InputCubit>();
    String errMsg = '';

    try {
      final parsedInput = await inputCubit.parseInput(input: _invoice);

      if (parsedInput is InputType_Bolt11) {
        final lnInvoice = parsedInput.invoice;
        _logger.info('handle LnInvoice ${lnInvoice.toFormattedString()}');

        // Check for zero amount Bolt11 invoices
        if (lnInvoice.amountMsat == BigInt.zero) {
          errMsg = 'Zero-amount lightning payments are not supported.';
        } else {
          handleLnInvoice(lnInvoice);
        }
      } else {
        errMsg = 'Unsupported input';
      }
    } catch (error) {
      final String errStr = error.toString();
      errMsg = errStr.contains('Unrecognized') ? 'Unsupported input' : errStr;
      _logger.warning('Input validation error: $errStr', error);
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _feedbackMessage = errMsg;
        });
        _feedbackController.forward(from: 0.0).then((_) {
          if (mounted) {
            _feedbackController.reverse();
          }
        });
      }
    }
  }

  Future<dynamic> handleLnInvoice(LNInvoice lnInvoice) async {
    _logger.info('handle LnInvoice ${lnInvoice.toFormattedString()}');
    final NavigatorState navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => LnPaymentPage(lnInvoice: lnInvoice),
      ),
    );
  }
}
