import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.isOnboardingComplete});
  final bool isOnboardingComplete;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _progressController;

  late Animation<double> _backgroundScale;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _overlayOpacity;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _backgroundScale = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeOut),
    );

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );

    _overlayOpacity = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start background animation immediately
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _progressController.forward();

    // Wait for progress animation to complete (2500ms) plus 3 seconds
    // await Future.delayed(const Duration(milliseconds: 3500));

    if (mounted) {
      if (widget.isOnboardingComplete) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/');
        });
      } else {
        Timer(const Duration(milliseconds: 3500), () {
          Navigator.of(context).pushReplacementNamed('/intro');
        });
      }
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _contentController,
          _progressController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Background Image
              FadeTransition(
                opacity: _backgroundOpacity,
                child: ScaleTransition(
                  scale: _backgroundScale,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
                    child: Image.asset(
                      'assets/legends/skibidi_satoshi.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Backdrop Overlay
              FadeTransition(
                opacity: _overlayOpacity,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
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
                ),
              ),

              // Content
              SafeArea(
                child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          _genzFloatingIcons(),

                          const SizedBox(height: 32),

                          // Title Section
                          Column(
                            children: [
                              Text(
                                'SKIBIDI SATOSHI',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2A2A2A),
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.8),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6B9EFF,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF6B9EFF,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'WALLET',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6B9EFF),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE8E8E8),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2A2A2A,
                                      ).withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'The most based Bitcoin wallet\nfor the next generation',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF6B6B6B),
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(flex: 3),

                          // Loading Section
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE8E8E8),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2A2A2A,
                                  ).withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Progress Bar
                                Container(
                                  width: double.infinity,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8E8E8),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _progressValue.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6B9EFF),
                                            Color(0xFFFF8FB8),
                                            Color(0xFFF7931A),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading the shit...',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFFB8B8B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _genzFloatingIcons() {
    return // Enhanced Hero Section with more Gen Z floating elements
    SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Bitcoin icon (existing)
          Positioned(
            top: 30,
            right: 40,
            child: TweenAnimationBuilder(
              duration: const Duration(seconds: 3),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, sin(value * 2 * pi) * 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7931A).withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7931A).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.currency_bitcoin,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),

          // Wallet icon (existing)
          Positioned(
            top: 60,
            left: 30,
            child: TweenAnimationBuilder(
              duration: const Duration(seconds: 4),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(sin(value * 2 * pi) * 8, 0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B9EFF).withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B9EFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),

          // NEW: "No Cap" badge
          Positioned(
            top: 180,
            left: 30,
            child: TweenAnimationBuilder(
              duration: const Duration(seconds: 4),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(sin(value * 2 * pi + 3) * 7, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D1FF).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D1FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'NO CAP',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // HODL badge (existing)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8FB8).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8FB8).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '💎 HODL',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
