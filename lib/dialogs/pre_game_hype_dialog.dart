import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreGameHypeDialog extends StatelessWidget {
  final VoidCallback onLetsGo;

  const PreGameHypeDialog({super.key, required this.onLetsGo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryWhite,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: AppTheme.charcoal.withOpacity(
                0.12,
              ), // Slightly more pronounced shadow
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: AppTheme.softBlue.withOpacity(0.5),
            width: 2,
          ), // Playful border
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header Section with Avatar/Meme
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 24.0,
              ),
              decoration: BoxDecoration(
                color: AppTheme.softGray.withOpacity(
                  0.7,
                ), // Light, neutral header
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22.0), // Adjusted for border
                  topRight: Radius.circular(22.0),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightGray.withOpacity(0.7),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Placeholder for NPC/Meme Avatar
                  // Replace this with your Image.asset if you have one
                  Text(
                    '😎👍', // Thumbs-up cool emoji as placeholder
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ready for the Mini-Game?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800, // Extra bold
                      color: AppTheme.charcoal,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Body Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        color: AppTheme.darkGray.withOpacity(0.95),
                        height: 1.65, // Slightly more spacing for emojis
                        fontWeight: FontWeight.w500,
                      ),
                      children: const [
                        TextSpan(
                          text:
                              "You’re about to enter the Skibidi Office, a wild 2D RPG where you’ll fight muddy and swampy enemies, collect your secret 12-word phrase, and prove you’re not just speedrunning 🏃💨.\n\n",
                        ),
                        TextSpan(
                          text:
                              "Defeat the baddies, grab your magic words, and unlock the door with a final quiz. No cap, your coins depend on it!",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.accentPink, // Playful pink button
                      foregroundColor: AppTheme.primaryWhite,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 30,
                      ), // Slightly larger padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 5,
                      shadowColor: AppTheme.accentPink.withOpacity(0.5),
                    ),
                    onPressed: onLetsGo,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Let’s Goooo!", // Extra 'o' for hype
                          style: GoogleFonts.poppins(
                            fontSize: 18, // Prominent button text
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '🚀🔥', // Rocket and Fire emoji combo
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the dialog (optional, but good practice)
Future<void> showPreGameHypeDialog(
  BuildContext context,
  VoidCallback onLetsGo,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button
    builder: (BuildContext dialogContext) {
      // You could add an animation here if desired, e.g., using showGeneralDialog
      return ScaleTransition(
        // Simple scale animation for entry
        scale: CurvedAnimation(
          parent: ModalRoute.of(dialogContext)!.animation!,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeOutCubic,
        ),
        child: PreGameHypeDialog(onLetsGo: onLetsGo),
      );
    },
  );
}
