import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LnPaymentDescription extends StatelessWidget {
  const LnPaymentDescription({required this.metadataText, super.key});

  final String metadataText;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Description:',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B4B4B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            metadataText,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF2A2A2A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
