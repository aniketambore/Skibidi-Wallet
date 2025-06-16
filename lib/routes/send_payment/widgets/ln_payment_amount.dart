import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LnPaymentAmount extends StatelessWidget {
  final int amountSat;
  final bool hasError;

  const LnPaymentAmount({
    required this.amountSat,
    required this.hasError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8B1A2).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasError
                  ? Colors.red.withOpacity(0.3)
                  : const Color(0xFFB8B1A2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Amount:',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B4B4B),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                '$amountSat SAT',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: hasError ? Colors.red : const Color(0xFF2A2A2A),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
