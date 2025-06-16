import 'package:bitwit_shit/routes/map/bitcoin_legend_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitwit_shit/routes/time_capsule/time_capsule_list_screen.dart';

class SkibidiToolsDialog extends StatelessWidget {
  const SkibidiToolsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Skibidi Tools',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToolItem(
                  iconPath: 'assets/3d_icons/time.png',
                  label: 'Time Capsule',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TimeCapsuleListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                _ToolItem(
                  iconPath: 'assets/3d_icons/trophy.png',
                  label: 'Bitcoin Level',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BitcoinLegendMapScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _ToolItem(
              iconPath: 'assets/3d_icons/lightning.png',
              label: 'More tools\ncoming soon',
              onTap: null,
              comingSoon: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Long press to access Skibidi tools!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;
  final bool comingSoon;

  const _ToolItem({
    required this.iconPath,
    required this.label,
    this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: comingSoon ? 0.5 : 1.0,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
