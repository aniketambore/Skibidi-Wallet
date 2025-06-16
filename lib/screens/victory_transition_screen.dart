import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VictoryTransitionScreen extends StatefulWidget {
  const VictoryTransitionScreen({super.key});

  @override
  State<VictoryTransitionScreen> createState() =>
      _VictoryTransitionScreenState();
}

class _VictoryTransitionScreenState extends State<VictoryTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _pulseController;
  late AnimationController _textAnimationController;
  late AnimationController _backgroundController;

  late Animation<double> _mainScale;
  late Animation<double> _mainOpacity;
  late Animation<double> _textSlideUp;
  late Animation<double> _textOpacity;
  late Animation<double> _subtextSlideUp;
  late Animation<double> _subtextOpacity;
  late Animation<double> _backgroundPulse;

  final Duration _transitionDuration = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();

    // Main animation for the GIF
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _mainScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _mainOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for the aura effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundPulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    // Text animations
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _textSlideUp = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _subtextSlideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _subtextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start main animation
    _mainAnimationController.forward();

    // Start text animations after a short delay
    await Future.delayed(const Duration(milliseconds: 600));
    _textAnimationController.forward();

    // Navigate to wallet home screen after transition duration
    Future.delayed(_transitionDuration, () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseController.dispose();
    _textAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Light pastel animated background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFDF6E3), // cream
              const Color(0xFFF8E1FF), // pastel pink
              const Color(0xFFE3F0FF), // pastel blue
              const Color(0xFFFFFDE3), // pastel yellow
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated pastel glow in background
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Center(
                  child: Container(
                    width: 600 + (_backgroundPulse.value * 100),
                    height: 600 + (_backgroundPulse.value * 100),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(
                            0xFF6B9EFF,
                          ).withOpacity(0.12 + _backgroundPulse.value * 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.2, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),

                  // Animated pastel border around GIF
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _mainAnimationController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _mainOpacity.value,
                        child: Transform.scale(
                          scale:
                              _mainScale.value *
                              (1 + _pulseController.value * 0.05),
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF8E1FF), // pastel pink
                                  Color(0xFFE3F0FF), // pastel blue
                                  Color(0xFFFFFDE3), // pastel yellow
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6B9EFF,
                                  ).withOpacity(0.18),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.12),
                                  blurRadius: 30,
                                  offset: const Offset(0, 0),
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(35),
                                  child: Image.asset(
                                    'assets/gifs/dragon_ball.gif',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6B9EFF),
                                              Color(0xFF8B5CF6),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.currency_bitcoin,
                                                size: 80,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                '🚀',
                                                style: TextStyle(fontSize: 40),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Meme badge
                                Positioned(
                                  top: 18,
                                  right: 18,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFF6B6B,
                                        ).withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'LFG!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Main text
                  AnimatedBuilder(
                    animation: _textAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textSlideUp.value),
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: Text(
                            'SKIBIDI SATOSHI',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2A2A2A),
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 15,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Subtext - ACTIVATED
                  AnimatedBuilder(
                    animation: _textAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _subtextSlideUp.value),
                        child: Opacity(
                          opacity: _subtextOpacity.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDE3),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF00D1FF),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'ABSOLUTELY REKT',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00D1FF),
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Additional text
                  AnimatedBuilder(
                    animation: _textAnimationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _subtextOpacity.value,
                        child: Text(
                          'WALLET POWER LEVEL OVER 9000! NO CAP 🚀',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2A2A2A).withOpacity(0.8),
                          ),
                        ),
                      );
                    },
                  ),

                  // Spacer at bottom
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
