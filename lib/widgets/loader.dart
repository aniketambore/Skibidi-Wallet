import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'transparent_page_route.dart';

class Loader extends StatelessWidget {
  final double? value;
  final String? label;
  final Color? color;
  final double strokeWidth;

  const Loader({
    super.key,
    this.value,
    this.label,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: FractionalOffset.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A2A2A).withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: value,
                  semanticsLabel: label,
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? const Color(0xFF6B9EFF),
                  ),
                ),
              ),
              if (label != null) ...[
                const SizedBox(height: 16),
                Text(
                  label!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFB8B8B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

TransparentPageRoute<void> createLoaderRoute(
  BuildContext context, {
  String message = '',
  double opacity = 0.5,
  Future<void>? action,
  VoidCallback? onClose,
}) {
  return TransparentPageRoute<void>((BuildContext context) {
    return TransparentRouteLoader(
      message: message,
      opacity: opacity,
      action: action,
      onClose: onClose,
    );
  });
}

class TransparentRouteLoader extends StatefulWidget {
  final String message;
  final double opacity;
  final Future<dynamic>? action;
  final Function? onClose;

  const TransparentRouteLoader({
    required this.message,
    super.key,
    this.opacity = 0.5,
    this.action,
    this.onClose,
  });

  @override
  State<StatefulWidget> createState() {
    return TransparentRouteLoaderState();
  }
}

class TransparentRouteLoaderState extends State<TransparentRouteLoader> {
  @override
  void initState() {
    super.initState();
    widget.action?.whenComplete(() {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenLoader(
      message: widget.message,
      opacity: widget.opacity,
      onClose: widget.onClose,
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  final String? message;
  final double opacity;
  final double? value;
  final Color? progressColor;
  final Color bgColor;
  final Function? onClose;

  const FullScreenLoader({
    super.key,
    this.message,
    this.opacity = 0.5,
    this.value,
    this.progressColor,
    this.bgColor = const Color(0xFFFAFAFA),
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final Size mediaQuerySize = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          // Backdrop with gradient
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFAFAFA).withOpacity(0.95),
                    const Color(0xFFFAFAFA).withOpacity(0.90),
                    const Color(0xFFFAFAFA).withOpacity(0.85),
                    const Color(0xFFFAFAFA).withOpacity(0.90),
                    const Color(0xFFFAFAFA).withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                ),
              ),
              height: mediaQuerySize.height,
              width: mediaQuerySize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Loader(
                    value: value,
                    label: message,
                    color: progressColor ?? const Color(0xFF6B9EFF),
                  ),
                ],
              ),
            ),
          ),
          if (onClose != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A2A2A).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => onClose!(),
                    icon: Icon(
                      Icons.close,
                      color: const Color(0xFF2A2A2A),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
