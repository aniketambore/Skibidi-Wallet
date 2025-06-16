import 'package:bitwit_shit/bloc/time_capsule/time_capsule_cubit.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_model.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:confetti/confetti.dart';

class TimeCapsuleDetailScreen extends StatefulWidget {
  final TimeCapsule capsule;

  const TimeCapsuleDetailScreen({super.key, required this.capsule});

  @override
  State<TimeCapsuleDetailScreen> createState() =>
      _TimeCapsuleDetailScreenState();
}

class _TimeCapsuleDetailScreenState extends State<TimeCapsuleDetailScreen> {
  // late ConfettiController _confettiController;
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    // _confettiController = ConfettiController(
    //   duration: const Duration(seconds: 3),
    // );
  }

  @override
  void dispose() {
    // _confettiController.dispose();
    super.dispose();
  }

  Future<void> _unlockCapsule() async {
    setState(() {
      _isUnlocking = true;
    });

    try {
      await context.read<TimeCapsuleCubit>().unlockCapsule(widget.capsule.id);
      if (mounted) {
        // _confettiController.play();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time capsule unlocked successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeUntilUnlock = widget.capsule.unlockDate.difference(
      DateTime.now(),
    );
    final isExpired = widget.capsule.isExpired;
    final isUnlocked = widget.capsule.isUnlocked;

    // Listen for errors in the state
    final state = context.watch<TimeCapsuleCubit>().state;
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                context.read<TimeCapsuleCubit>().clearError();
              },
            ),
          ),
        );
      });
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF), // white
            Color(0xFFF5F5F5), // very light gray
            Color(0xFFE3F0FF), // hint of blue at the bottom
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Time Capsule Details',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Status Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildStatusIcon(isExpired, isUnlocked),
                        const SizedBox(height: 16),
                        Text(
                          _getStatusText(isExpired, isUnlocked),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.charcoal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!isUnlocked) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isExpired
                                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                                      : const Color(
                                        0xFFFF6B6B,
                                      ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isExpired
                                        ? const Color(
                                          0xFF4CAF50,
                                        ).withOpacity(0.3)
                                        : const Color(
                                          0xFFFF6B6B,
                                        ).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              isExpired
                                  ? 'Ready to unlock!'
                                  : 'Unlocks in: ${_formatDuration(timeUntilUnlock)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isExpired
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFFF6B6B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Card
                _buildInfoCard(
                  title: 'Amount Locked',
                  value: '${widget.capsule.amountSat} sats',
                  icon: Icons.currency_bitcoin,
                ),
                const SizedBox(height: 16),

                // Dates Card
                _buildInfoCard(
                  title: 'Created On',
                  value: DateFormat(
                    'MMMM d, y',
                  ).format(widget.capsule.createdAt),
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  title: 'Unlock Date',
                  value: DateFormat(
                    'MMMM d, y',
                  ).format(widget.capsule.unlockDate),
                  icon: Icons.lock_clock,
                ),
                const SizedBox(height: 24),

                // Message Card
                if (widget.capsule.message.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.message, color: AppTheme.charcoal),
                              const SizedBox(width: 12),
                              Text(
                                'Message to Future Self',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.charcoal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.capsule.message,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.charcoal,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Unlock Button
                if (isExpired && !isUnlocked)
                  Material(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(15),
                    elevation: 2,
                    shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
                    child: InkWell(
                      onTap: _isUnlocking ? null : _unlockCapsule,
                      borderRadius: BorderRadius.circular(15),
                      splashColor: Colors.white.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: Center(
                          child:
                              _isUnlocking
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Unlock Time Capsule',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Confetti
            // Align(
            //   alignment: Alignment.topCenter,
            //   child: ConfettiWidget(
            //     confettiController: _confettiController,
            //     blastDirection: pi / 2,
            //     maxBlastForce: 5,
            //     minBlastForce: 2,
            //     emissionFrequency: 0.05,
            //     numberOfParticles: 50,
            //     gravity: 0.1,
            //     shouldLoop: false,
            //     colors: const [
            //       Colors.green,
            //       Colors.blue,
            //       Colors.pink,
            //       Colors.orange,
            //       Colors.purple,
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isExpired, bool isUnlocked) {
    if (isUnlocked) {
      return const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 64);
    }
    if (isExpired) {
      return const Icon(Icons.lock_open, color: Color(0xFFFF6B6B), size: 64);
    }
    return Icon(Icons.lock, color: AppTheme.charcoal, size: 64);
  }

  String _getStatusText(bool isExpired, bool isUnlocked) {
    if (isUnlocked) {
      return 'Unlocked';
    }
    if (isExpired) {
      return 'Ready to Unlock';
    }
    return 'Locked';
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.charcoal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoal,
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

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes';
    }
    return '${duration.inSeconds} seconds';
  }
}
