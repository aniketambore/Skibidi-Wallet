import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

void showPaymentReceivedDialog(BuildContext context, {int? amountSat}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => PaymentReceivedDialog(amountSat: amountSat),
  );
}

class PaymentReceivedDialog extends StatelessWidget {
  final int? amountSat;
  const PaymentReceivedDialog({super.key, this.amountSat});

  @override
  Widget build(BuildContext context) {
    // Launch confetti after the first build
    Future.microtask(() {
      Confetti.launch(
        context,
        options: const ConfettiOptions(particleCount: 100, spread: 70, y: 0.6),
      );
    });

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
              const SizedBox(height: 32),
              Image.asset('assets/gifs/dance.gif', fit: BoxFit.contain),
              const SizedBox(height: 18),
              // Title
              Text(
                'Payment Received!',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.charcoal,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: AppTheme.primaryWhite.withOpacity(0.7),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (amountSat != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9EFF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6B9EFF).withOpacity(0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '+$amountSat sats',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B9EFF),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B9EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Awesome!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
