import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:bitwit_shit/services/external_browser_service.dart';

class PaymentInfoMessageBox extends StatelessWidget {
  final String message;
  final String? linkUrl;

  const PaymentInfoMessageBox({required this.message, this.linkUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final Widget content =
        linkUrl != null
            ? RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.charcoal,
                  height: 1.4,
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: ' here',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentPink,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap =
                              () => ExternalBrowserService.launchLink(
                                context,
                                linkAddress: linkUrl!,
                              ),
                  ),
                  TextSpan(
                    text: '.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoal,
                    ),
                  ),
                ],
              ),
            )
            : Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoal,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: content,
    );
  }
}
