import 'package:bitwit_shit/bloc/account/account_cubit.dart';
import 'package:bitwit_shit/bloc/account/account_state.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_cubit.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_state.dart';
import 'package:bitwit_shit/dialogs/skibidi_tools_dialog.dart';
import 'package:bitwit_shit/routes/home/placeholder_balance.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:bitwit_shit/utils/bitcoin_legends.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' show cos, sin, pi, Random;
import '../receive_payment/receive_screen.dart';
import '../send_payment/send_screen.dart';
import 'dart:async';
import 'transaction_history_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'wallet_tutorial_overlay.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;
  late AnimationController _floatingController;
  late AnimationController _memeTextController;
  String _currentMemeText = '';
  final List<String> _memeTexts = [
    'NO CAP FR FR',
    'SKIBIDI BALLIN',
    'TO THE MOON 🚀',
    'WAGMI',
    'LET\'S GOOOO',
    'HODL GANG!',
    'STACKIN\' SATS 🧱',
    'NOT YOUR KEYS 🔑 NOT YOUR COINS',
    'FOMO ENGAGED 📈',
    'SATS UP OR I RIOT 🔥',
    'NGMI IF YOU SELL 😤',
    'ORANGE PILL TAKEN 💊',
    'MAXI MODE: ON 🧠',
    'SATOSHI VIBES ONLY 🤌',
    'HODL OR CRY 😭',
    'BLOCK HEIGHT GO BRRR ⛓️',
    'KYC? NAH, I\'M GOOD 🚫',
    'EXIT FIAT. ENTER FREEDOM 🛸',
  ];

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _memeTextController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _startMemeTextAnimation();
  }

  void _startMemeTextAnimation() {
    _memeTextController.forward().then((_) {
      _memeTextController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentMemeText = _memeTexts[Random().nextInt(_memeTexts.length)];
          });
          _startMemeTextAnimation();
        }
      });
    });
  }

  void _dismissTutorial() {
    context.read<AccountCubit>().markShowcaseAsShown();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _memeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: const BoxDecoration(
      //   gradient: RadialGradient(
      //     colors: [Color(0xFFC6C0B3), Color(0xFFB8B1A2)],
      //     center: Alignment.center,
      //     radius: 1.0,
      //   ),
      // ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF), // white
            Color(0xFFF5F5F5), // very light gray
            Color(0xFFE3F0FF), // hint of blue at the bottom
          ],
          stops: [0.0, 0.7, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Floating Gen Z Elements
            _buildFloatingElements(),

            // Meme Text
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _memeTextController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _memeTextController.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _memeTextController.value)),
                      child: Text(
                        _currentMemeText,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkGray,
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
                    ),
                  );
                },
              ),
            ),

            // Main PageView
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                const ReceiveScreen(),

                _Pokemon3DCard(),
                const SendScreen(),
              ],
            ),

            BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                return state.hasShownShowcase
                    ? const SizedBox.shrink()
                    : WalletTutorialOverlay(onDismiss: _dismissTutorial);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Floating Bitcoin
        Positioned(
          top: 40,
          right: 30,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, sin(_floatingController.value * 2 * pi) * 8),
                child: Transform.rotate(
                  angle: -0.10,
                  child: SizedBox(
                    width: 74,
                    height: 74,
                    child: Image.asset('assets/3d_icons/bitcoin.png'),
                  ),
                ),
              );
            },
          ),
        ),

        // Floating Skibidi
        // Positioned(
        //   bottom: 20,
        //   left: 15,
        //   child: AnimatedBuilder(
        //     animation: _floatingController,
        //     builder: (context, child) {
        //       return Transform.translate(
        //         offset: Offset(
        //           sin(_floatingController.value * 2 * pi + 1) * 10,
        //           0,
        //         ),
        //         child: SizedBox(
        //           width: 74,
        //           height: 74,
        //           child: Image.asset('assets/3d_icons/lightning.png'),
        //         ),
        //       );
        //     },
        //   ),
        // ),

        // Floating "BASED" badge
        // Positioned(
        //   bottom: 10,
        //   right: 40,
        //   child: AnimatedBuilder(
        //     animation: _floatingController,
        //     builder: (context, child) {
        //       return Transform.translate(
        //         offset: Offset(
        //           cos(_floatingController.value * 2 * pi + 2) * 6,
        //           sin(_floatingController.value * 2 * pi + 2) * 4,
        //         ),
        //         child: Container(
        //           padding: const EdgeInsets.symmetric(
        //             horizontal: 10,
        //             vertical: 5,
        //           ),
        //           decoration: BoxDecoration(
        //             color: const Color(0xFFFF6B6B),
        //             borderRadius: BorderRadius.circular(15),
        //             boxShadow: [
        //               BoxShadow(
        //                 color: const Color(0xFFFF6B6B).withOpacity(0.4),
        //                 blurRadius: 10,
        //                 offset: const Offset(0, 3),
        //               ),
        //             ],
        //           ),
        //           child: Text(
        //             'BASED',
        //             style: GoogleFonts.poppins(
        //               fontSize: 10,
        //               fontWeight: FontWeight.w700,
        //               color: Colors.white,
        //               letterSpacing: 1,
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

class _Pokemon3DCard extends StatefulWidget {
  @override
  State<_Pokemon3DCard> createState() => _Pokemon3DCardState();
}

class _Pokemon3DCardState extends State<_Pokemon3DCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  bool _showBalance = false;
  Timer? _hideTimer;

  BitcoinLegendType _getLegendTypeFromBalance(int balance) {
    if (balance >= 10000000) {
      // 10M sats
      return BitcoinLegendType.skibidiSatoshi; // OG for whales
    } else if (balance >= 5000000) {
      // 5M sats
      return BitcoinLegendType.skibidiAdamBack; // Cyberpunk for high rollers
    } else if (balance >= 2000000) {
      // 2M sats
      return BitcoinLegendType.skibidiHalFinney; // Legend for serious stackers
    } else if (balance >= 1000000) {
      // 1M sats
      return BitcoinLegendType
          .skibidiNickSzabo; // Architect for dedicated plebs
    } else if (balance >= 500000) {
      // 500K sats
      return BitcoinLegendType.skibidiPieterWuille; // Wizard for advanced users
    } else if (balance >= 200000) {
      // 200K sats
      return BitcoinLegendType
          .skibidiAndreasAntonopoulos; // Sensei for learners
    } else if (balance >= 100000) {
      // 100K sats
      return BitcoinLegendType.skibidiJosephPoon; // Trailblazer for enthusiasts
    } else if (balance >= 50000) {
      // 50K sats
      return BitcoinLegendType
          .skibidiTadgeDryja; // Lightning OG for early adopters
    } else if (balance >= 20000) {
      // 20K sats
      return BitcoinLegendType.skibidiLuke; // Core OG for beginners
    } else if (balance >= 10000) {
      // 10K sats
      return BitcoinLegendType
          .skibidiUncleRockstarDev; // Rockstar for community members
    } else if (balance >= 5000) {
      // 5K sats
      return BitcoinLegendType.skibidiJimmySong; // Cowboy for regular users
    } else if (balance >= 1000) {
      // 1K sats
      return BitcoinLegendType.skibidiSuperTestnet; // Hacker for tech-savvy
    } else if (balance >= 500) {
      // 100 sats
      return BitcoinLegendType.skibidiJackDorsey; // Visionary for new users
    } else {
      return BitcoinLegendType.skibidiBob; // Newbie for everyone else
    }
  }

  Widget _buildLegendImage(String imagePath) {
    // Check if the image is a local asset or remote URL
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/legends/skibidi_bob.png',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget:
            (context, url, error) => Image.asset(
              'assets/legends/skibidi_bob.png',
              fit: BoxFit.cover,
            ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _gradientAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // Full rotation in radians
    ).animate(_gradientController);
  }

  void _showBalanceCard() {
    setState(() {
      _showBalance = true;
    });

    // Cancel any existing timer
    _hideTimer?.cancel();

    // Set new timer to hide the balance card
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showBalance = false;
        });
      }
    });
  }

  void _showTransactions() {
    final controller = DraggableScrollableController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            controller: controller,
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) =>
                    TransactionHistorySheet(scrollController: scrollController),
          ),
    ).whenComplete(() {
      controller.dispose();
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        final balance = accountState.walletInfo?.balanceSat.toInt() ?? 0;
        final legendType = _getLegendTypeFromBalance(balance);
        final legend = BitcoinLegend.fromType(legendType);

        return GestureDetector(
          onDoubleTap: _showBalanceCard,
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              // Swipe up
              _showTransactions();
            }
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => SkibidiToolsDialog(),
            );
          },
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(
                  top: _showBalance ? 100 : 40,
                  left: 24,
                  right: 24,
                  bottom: 40,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated gradient border
                      AnimatedBuilder(
                        animation: _gradientAnimation,
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(38),
                              gradient: LinearGradient(
                                begin: Alignment(
                                  cos(_gradientAnimation.value),
                                  sin(_gradientAnimation.value),
                                ),
                                end: Alignment(
                                  -cos(_gradientAnimation.value),
                                  -sin(_gradientAnimation.value),
                                ),
                                colors: const [
                                  Color(0xFFFDF6E3),
                                  Color(0xFFD6CFC0),
                                  Color(0xFFFDF6E3),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Card base with 3D effect
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        margin: const EdgeInsets.all(
                          3,
                        ), // Add margin to show the animated border
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFDF6E3), Color(0xFFD6CFC0)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 10,
                              offset: const Offset(-6, -6),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFB8B1A2),
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              // Title
                              Text(
                                legend.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
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
                              const SizedBox(height: 10),
                              // Image
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: _buildLegendImage(legend.image),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Subtitle
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0,
                                ),
                                child: Text(
                                  legend.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4B4B4B),
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB8B1A2,
                                  ).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Level: ${legend.level}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2A2A2A),
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Card border highlight for extra 3D pop
                      IgnorePointer(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                              width: 6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showBalance)
                Positioned(
                  top: 70,
                  left: 24,
                  right: 24,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showBalance ? 1.0 : 0.0,
                    child: const _BalanceCard(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceCard extends StatefulWidget {
  const _BalanceCard();

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isShaking = false;
        });
      }
    });
  }

  void _startShake() {
    if (!_isShaking) {
      setState(() {
        _isShaking = true;
      });
      _shakeController.forward();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startShake,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _shakeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFDF6E3), Color(0xFFD6CFC0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Balance',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF4B4B4B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('💎', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<AccountCubit, AccountState>(
                          builder: (context, accountState) {
                            final bool showBalance =
                                !accountState.isRestoring &&
                                accountState.walletInfo != null;

                            if (!showBalance) {
                              return const PlaceholderBalanceText();
                            }

                            final totalBalance =
                                accountState.walletInfo?.balanceSat.toInt() ??
                                0;

                            return BlocBuilder<
                              TimeCapsuleCubit,
                              TimeCapsuleState
                            >(
                              builder: (context, timeCapsuleState) {
                                // Calculate locked balance from time capsules
                                final lockedBalance =
                                    timeCapsuleState.capsules
                                        .where((capsule) => !capsule.isUnlocked)
                                        .fold<BigInt>(
                                          BigInt.zero,
                                          (sum, capsule) =>
                                              sum + capsule.amountSat,
                                        )
                                        .toInt() ??
                                    0;

                                final spendableBalance =
                                    totalBalance - lockedBalance;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '₿ $totalBalance',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF2A2A2A),
                                            letterSpacing: 1.1,
                                            shadows: [
                                              Shadow(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                offset: const Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF6B9EFF,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF6B9EFF,
                                              ).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            'WAGMI',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF6B9EFF),
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (lockedBalance > 0) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFFF6B6B,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFFFF6B6B,
                                                ).withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              'Locked: ₿ $lockedBalance',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFFF6B6B),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF4CAF50,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF4CAF50,
                                                ).withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              'Spendable: ₿ $spendableBalance',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF4CAF50),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8B1A2).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF2A2A2A),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
