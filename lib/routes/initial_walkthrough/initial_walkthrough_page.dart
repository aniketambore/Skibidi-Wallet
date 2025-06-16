import 'dart:math';
import 'package:bitwit_shit/dialogs/pre_game_hype_dialog.dart';
import 'package:bitwit_shit/routes/initial_walkthrough/initial_walkthrough_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

final _log = Logger("InitialWalkthroughPage");

class InitialWalkthroughPage extends StatefulWidget {
  const InitialWalkthroughPage({super.key});

  @override
  State<InitialWalkthroughPage> createState() => _InitialWalkthroughPageState();
}

class _InitialWalkthroughPageState extends State<InitialWalkthroughPage>
    with TickerProviderStateMixin {
  late AnimationController _penguinController;
  late AnimationController _contentController;
  late AnimationController _floatingController;
  late AnimationController _createButtonController;
  late AnimationController _memeGifController;

  late Animation<Offset> _penguinSlide;
  late Animation<double> _penguinScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _floatingAnimation;
  late Animation<double> _createButtonScale;
  late Animation<double> _memeGifOpacity;
  late Animation<double> _memeGifScale;

  bool _showPenguin = true;
  bool _showMemeGif = false;

  @override
  void initState() {
    super.initState();

    _penguinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _createButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _memeGifController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _penguinSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(parent: _penguinController, curve: Curves.easeInBack),
    );

    _penguinScale = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _penguinController, curve: Curves.easeInBack),
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

    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_floatingController);

    _createButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _createButtonController, curve: Curves.easeInOut),
    );

    _memeGifOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _memeGifController, curve: Curves.easeIn),
    );

    _memeGifScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _memeGifController, curve: Curves.elasticOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start floating animations immediately
    _floatingController.repeat();

    // Show penguin rocket for 2 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    _penguinController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _showPenguin = false;
    });

    // Show main content
    _contentController.forward();
  }

  void _onCreateWalletTap() async {
    final InitialWalkthroughService walkthroughService =
        InitialWalkthroughService(context);

    // Button squish animation
    _createButtonController.forward().then((_) {
      _createButtonController.reverse();
    });

    // Show the pre-game hype dialog
    await showPreGameHypeDialog(context, () async {
      // This callback is executed when "Let's Go!" is tapped in the dialog
      Navigator.of(context).pop(); // Dismiss the dialog

      // Show meme GIF
      setState(() {
        _showMemeGif = true;
      });
      _memeGifController.forward();

      // Hide meme GIF after 3 seconds and navigate to game
      await Future.delayed(const Duration(milliseconds: 2000));

      _memeGifController.reverse().then((_) {
        setState(() {
          _showMemeGif = false;
        });

        walkthroughService.registerWallet();
      });
    });
  }

  Future<void> _onRestoreWalletTap({
    List<String>? initialWords,
    String? errorMessage,
  }) async {
    _log.info('Restore wallet from mnemonic seed');
    final InitialWalkthroughService walkthroughService =
        InitialWalkthroughService(context);

    await walkthroughService.restoreWallet(
      initialWords: initialWords,
      errorMessage: errorMessage,
    );
  }

  @override
  void dispose() {
    _penguinController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    _createButtonController.dispose();
    _memeGifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Background with subtle pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFFAFAFA), const Color(0xFFF5F5F5)],
              ),
            ),
          ),

          // Penguin Rocket GIF Animation
          if (_showPenguin)
            Center(
              child: SlideTransition(
                position: _penguinSlide,
                child: ScaleTransition(
                  scale: _penguinScale,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B9EFF).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/gifs/penguin_rocket.gif',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if GIF not found
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B9EFF), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🐧', style: TextStyle(fontSize: 60)),
                                  SizedBox(height: 10),
                                  Text('🚀', style: TextStyle(fontSize: 40)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Main Content
          if (!_showPenguin)
            SafeArea(
              child: SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // Floating Gen Z Elements
                        _buildFloatingElements(),

                        const SizedBox(height: 40),

                        // Title Section
                        _buildTitleSection(),

                        const Spacer(flex: 2),

                        // Buttons Section
                        _buildButtonsSection(),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Toilet Meme GIF Overlay
          if (_showMemeGif)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: FadeTransition(
                  opacity: _memeGifOpacity,
                  child: ScaleTransition(
                    scale: _memeGifScale,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFFF8FB8),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8FB8).withOpacity(0.6),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: Stack(
                          children: [
                            // Toilet Meme GIF
                            Image.asset(
                              'assets/gifs/toilet_meme.gif', // PLACEHOLDER - Replace with your actual toilet meme GIF
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback if GIF not found
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
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '🚽',
                                          style: TextStyle(fontSize: 80),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'LET\'S GOOO!',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '🚀💎',
                                          style: TextStyle(fontSize: 40),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Overlay text
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'WALLET CREATION INITIATED! 🚀',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Floating Bitcoin
          Positioned(
            top: 20,
            right: 30,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, sin(_floatingAnimation.value * 2 * pi) * 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7931A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7931A).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.currency_bitcoin,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating Rocket
          Positioned(
            top: 60,
            left: 20,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    sin(_floatingAnimation.value * 2 * pi + 1) * 10,
                    0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF66D9A6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF66D9A6).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating "BASED" badge
          Positioned(
            top: 120,
            right: 60,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    cos(_floatingAnimation.value * 2 * pi + 2) * 6,
                    sin(_floatingAnimation.value * 2 * pi + 2) * 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'BASED',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'READY TO GET',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2A2A2A),
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'ABSOLUTELY',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF6B9EFF),
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'REKT? 🚀',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFF8FB8),
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E8E8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Choose your path to financial freedom\n(or financial ruin, no cap)',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF6B6B6B),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      children: [
        // Create Wallet Button
        ScaleTransition(
          scale: _createButtonScale,
          child: GestureDetector(
            onTap: _onCreateWalletTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B9EFF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF2A2A2A), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B9EFF).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    'CREATE WALLET',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('💎', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Restore Wallet Button
        GestureDetector(
          onTap: () => _onRestoreWalletTap(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF2A2A2A), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔄', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'RESTORE WALLET',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2A2A2A),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Meme disclaimer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD93D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFFD93D).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Not financial advice. DYOR. Diamond hands only. 💎🙌',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
