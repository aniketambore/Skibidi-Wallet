import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LnurlPaymentHeader extends StatefulWidget {
  final String payeeName;
  final int totalAmount;
  final String errorMessage;

  const LnurlPaymentHeader({
    super.key,
    required this.payeeName,
    required this.totalAmount,
    required this.errorMessage,
  });

  @override
  State<LnurlPaymentHeader> createState() => _LnurlPaymentHeaderState();
}

class _LnurlPaymentHeaderState extends State<LnurlPaymentHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Column(
        children: [
          if (widget.payeeName.isNotEmpty)
            Text(
              widget.payeeName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2A2A),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Text(
            widget.payeeName.isEmpty
                ? 'You are requested to pay:'
                : 'is requesting you to pay:',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF4B4B4B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.totalAmount} SAT',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2A2A2A),
              letterSpacing: 1.1,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                widget.errorMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
