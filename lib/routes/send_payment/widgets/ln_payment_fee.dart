import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LnPaymentFee extends StatelessWidget {
  final bool isCalculatingFees;
  final int? feesSat;

  const LnPaymentFee({
    required this.isCalculatingFees,
    required this.feesSat,
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
          color: const Color(0xFFB8B1A2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Fee:',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B4B4B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child:
                  isCalculatingFees
                      ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: const Color(0xFFB8B1A2),
                        ),
                      )
                      : feesSat != null
                      ? Text(
                        "+${feesSat!} SAT",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A2A2A),
                        ),
                        textAlign: TextAlign.right,
                      )
                      : Text(
                        '? SAT',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
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
