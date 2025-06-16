import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Example usage in your game
void showMnemonicDialog(
  BuildContext context,
  List<String> words,
  bool isFirstHalf,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => MnemonicRevealDialog(
          mnemonicWords: words,
          isFirstHalf: isFirstHalf,
          onConfirm: () {
            Navigator.of(context).pop();
          },
        ),
  );
}

class MnemonicRevealDialog extends StatefulWidget {
  final List<String> mnemonicWords;
  final bool isFirstHalf; // true for first 6 words, false for last 6
  final VoidCallback onConfirm;

  const MnemonicRevealDialog({
    super.key,
    required this.mnemonicWords,
    required this.isFirstHalf,
    required this.onConfirm,
  });

  @override
  State<MnemonicRevealDialog> createState() => _MnemonicRevealDialogState();
}

class _MnemonicRevealDialogState extends State<MnemonicRevealDialog>
    with TickerProviderStateMixin {
  late AnimationController _catController;
  late AnimationController _wordsController;
  late AnimationController _buttonController;
  late AnimationController _dabbingController;

  late Animation<double> _catBounce;
  late Animation<double> _buttonScale;
  late Animation<double> _dabbingBounce;

  final List<AnimationController> _wordControllers = [];
  final List<Animation<Offset>> _wordPositions = [];
  final List<Animation<double>> _wordRotations = [];
  final List<Animation<double>> _wordScales = [];

  bool _showWords = false;

  @override
  void initState() {
    super.initState();

    _catController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _wordsController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _dabbingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _catBounce = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _catController, curve: Curves.easeInOut));

    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _dabbingBounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _dabbingController, curve: Curves.elasticOut),
    );

    _initializeWordAnimations();
    _startAnimations();
  }

  void _initializeWordAnimations() {
    for (int i = 0; i < widget.mnemonicWords.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 800 + (i * 200)),
        vsync: this,
      );

      final position = Tween<Offset>(
        begin: const Offset(0, 0), // Start from cat center
        end: Offset(
          (cos(i * pi / 3) * 1.2), // Spread wider in circle
          (sin(i * pi / 3) * 0.8) - 0.2, // Move up but not too much
        ),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

      final rotation = Tween<double>(
        begin: 0,
        end: (i % 2 == 0 ? 1 : -1) * pi / 8, // Smaller rotation
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

      final scale = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

      _wordControllers.add(controller);
      _wordPositions.add(position);
      _wordRotations.add(rotation);
      _wordScales.add(scale);
    }
  }

  void _startAnimations() async {
    // Start dabbing animation
    _dabbingController.repeat(reverse: true);

    // Start cat vibing
    _catController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 1000));

    // Show words one by one
    setState(() {
      _showWords = true;
    });

    for (int i = 0; i < _wordControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _wordControllers[i].forward();
    }
  }

  void _onButtonTap() {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });
    widget.onConfirm();
  }

  @override
  void dispose() {
    _catController.dispose();
    _wordsController.dispose();
    _buttonController.dispose();
    _dabbingController.dispose();
    for (var controller in _wordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAFAFA), Color(0xFFF0F0F0)],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with dabbing GIF - FIXED: Added proper padding
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                25,
                20,
                20,
              ), // Added top padding
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B9EFF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Column(
                children: [
                  // Dabbing GIF
                  AnimatedBuilder(
                    animation: _dabbingBounce,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_dabbingBounce.value * 0.2),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              'assets/gifs/dab.gif', // PLACEHOLDER - Replace with your dabbing GIF
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF8FB8),
                                        Color(0xFFFF6B6B),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '😎',
                                      style: TextStyle(fontSize: 40),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.isFirstHalf
                        ? 'FIRST ENEMY DOWN!'
                        : 'SECOND ENEMY REKT!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5), // FIXED: Added spacing
                  Text(
                    widget.isFirstHalf
                        ? 'Here\'s your first 6 words'
                        : 'Final 6 words unlocked!',
                    style: GoogleFonts.inter(
                      fontSize: 13, // FIXED: Increased font size
                      fontWeight: FontWeight.w500, // FIXED: Added font weight
                      color: Colors.white.withOpacity(
                        0.95,
                      ), // FIXED: Better opacity
                    ),
                  ),
                ],
              ),
            ),

            // Mnemonic words area - FIXED: Better spacing
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  30,
                  20,
                  20,
                ), // More top padding
                child: Stack(
                  children: [
                    // Cat Vibing GIF (center) - REPLACED toilet bowl
                    Center(
                      child: AnimatedBuilder(
                        animation: _catBounce,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _catBounce.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6B9EFF,
                                  ).withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6B9EFF,
                                    ).withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  widget.isFirstHalf
                                      ? 'assets/gifs/cat_vibing.gif'
                                      : "assets/gifs/baby_yes.gif", // PLACEHOLDER - Replace with your cat vibing GIF
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF66D9A6),
                                            Color(0xFF6B9EFF),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '🐱\n🎵',
                                          style: TextStyle(fontSize: 30),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Mnemonic words as toilet paper squares
                    if (_showWords)
                      ...List.generate(widget.mnemonicWords.length, (index) {
                        return AnimatedBuilder(
                          animation: Listenable.merge([
                            _wordPositions[index],
                            _wordRotations[index],
                            _wordScales[index],
                          ]),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                _wordPositions[index].value.dx *
                                    120, // Reduced spread
                                _wordPositions[index].value.dy * 120,
                              ),
                              child: Transform.rotate(
                                angle: _wordRotations[index].value,
                                child: Transform.scale(
                                  scale: _wordScales[index].value,
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      child: CustomPaint(
                                        size: const Size(
                                          90,
                                          55,
                                        ), // Slightly smaller
                                        painter: ToiletPaperPainter(),
                                        child: Container(
                                          width: 90,
                                          height: 55,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${widget.isFirstHalf ? index + 1 : index + 7}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF6B6B6B,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                widget.mnemonicWords[index],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF2A2A2A,
                                                  ),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Instructions and button
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Gen Z instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD93D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFFFD93D).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '📝 WRITE THESE DOWN, NO CAP!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2A2A2A),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Grab a pen and paper (yes, actual paper) and write these words down IN ORDER. Don\'t screenshot - that\'s not secure, bestie! 💀',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B6B6B),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm button
                  ScaleTransition(
                    scale: _buttonScale,
                    child: GestureDetector(
                      onTap: _onButtonTap,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8FB8), Color(0xFFFF6B6B)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8FB8).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('✅', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Text(
                              'I Got \'Em, Skibidi!',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text('🚽', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
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

// Keep the same ToiletPaperPainter class
class ToiletPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width, size.height),
        const Radius.circular(8),
      ),
      paint,
    );

    // Paper background
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      paint,
    );

    // Paper texture lines
    paint.color = const Color(0xFFE8E8E8);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * i / 4),
        Offset(size.width * 0.9, size.height * i / 4),
        paint,
      );
    }

    // Border
    paint.color = const Color(0xFF6B9EFF).withOpacity(0.3);
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
