import 'package:another_flushbar/flushbar.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Flushbar<dynamic> showFlushbar(
  BuildContext context, {
  String? title,
  Widget? icon,
  bool isDismissible = true,
  bool showMainButton = true,
  String? message,
  Widget? messageWidget,
  String? buttonText,
  FlushbarPosition position = FlushbarPosition.BOTTOM,
  bool Function()? onDismiss,
  Duration duration = const Duration(seconds: 8),
}) {
  Flushbar<dynamic>? flush;
  flush = Flushbar<dynamic>(
    isDismissible: isDismissible,
    flushbarPosition: position,
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(20),
    boxShadows: [
      BoxShadow(
        color: const Color(0xFF2A2A2A).withOpacity(0.08),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
    titleText:
        title == null
            ? null
            : Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2A2A),
              ),
            ),
    icon:
        icon != null
            ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9EFF).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6B9EFF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: icon,
            )
            : null,
    duration: duration == Duration.zero ? null : duration,
    messageText:
        messageWidget ??
        Text(
          message ?? '',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF6B6B6B),
            height: 1.4,
          ),
          textAlign: TextAlign.left,
        ),
    backgroundColor: Colors.white,
    borderColor: const Color(0xFFE8E8E8),
    borderWidth: 1,
    mainButton:
        !showMainButton
            ? null
            : Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentPink,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton(
                onPressed: () {
                  final bool dismiss = onDismiss != null ? onDismiss() : true;
                  if (dismiss) {
                    flush!.dismiss(true);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  buttonText ?? 'OK',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
  )..show(context);

  return flush;
}

void popFlushbars(BuildContext context) {
  Navigator.popUntil(context, (Route<dynamic> route) {
    return route.settings.name != FLUSHBAR_ROUTE_NAME;
  });
}
