import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class PlaceholderBalanceText extends StatelessWidget {
  const PlaceholderBalanceText({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFB8B1A2).withOpacity(0.3),
      highlightColor: const Color(0xFFFDF6E3).withOpacity(0.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFB8B1A2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFB8B1A2).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₿',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2A2A2A).withOpacity(0.5),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '••••••',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2A2A2A).withOpacity(0.5),
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
