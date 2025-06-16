import 'package:bitwit_shit/bloc/time_capsule/time_capsule_cubit.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_model.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_state.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' show pi, sin;

import 'create_time_capsule_screen.dart';
import 'time_capsule_detail_screen.dart';

class TimeCapsuleListScreen extends StatefulWidget {
  const TimeCapsuleListScreen({super.key});

  @override
  State<TimeCapsuleListScreen> createState() => _TimeCapsuleListScreenState();
}

class _TimeCapsuleListScreenState extends State<TimeCapsuleListScreen> {
  @override
  Widget build(BuildContext context) {
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
            'Time Capsules',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTimeCapsuleScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TimeCapsuleCubit, TimeCapsuleState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'Retry',
                      onPressed: () {
                        context.read<TimeCapsuleCubit>().clearError();
                      },
                    ),
                  ),
                );
              });
            }

            if (state.capsules.isEmpty) {
              return _NoTimeCapsules();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.capsules.length,
              itemBuilder: (context, index) {
                final capsule = state.capsules[index];
                return _TimeCapsuleCard(capsule: capsule);
              },
            );
          },
        ),
      ),
    );
  }
}

class _TimeCapsuleCard extends StatelessWidget {
  final TimeCapsule capsule;

  const _TimeCapsuleCard({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final timeUntilUnlock = capsule.unlockDate.difference(DateTime.now());
    final isExpired = capsule.isExpired;
    final isUnlocked = capsule.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(color: const Color(0xFFB8B1A2), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimeCapsuleDetailScreen(capsule: capsule),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${capsule.amountSat} sats',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A2A2A),
                      ),
                    ),
                    _buildStatusBadge(isExpired, isUnlocked),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.darkGray,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${DateFormat('MMM d, y').format(capsule.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        // color: const Color(0xFF4B4B4B).withOpacity(0.7),
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.lock_clock, size: 16, color: AppTheme.darkGray),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocks: ${DateFormat('MMM d, y').format(capsule.unlockDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ],
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isExpired
                              ? const Color(0xFF4CAF50).withOpacity(0.1)
                              : const Color(0xFFFF6B6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isExpired
                                ? const Color(0xFF4CAF50).withOpacity(0.3)
                                : const Color(0xFFFF6B6B).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isExpired
                          ? 'Ready to unlock!'
                          : 'Unlocks in: ${_formatDuration(timeUntilUnlock)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isExpired
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
                if (capsule.message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFB8B1A2)),
                  const SizedBox(height: 12),
                  Text(
                    capsule.message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF4B4B4B),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired, bool isUnlocked) {
    Color badgeColor;
    IconData icon;
    String text;

    if (isUnlocked) {
      badgeColor = const Color(0xFF4CAF50);
      icon = Icons.check_circle;
      text = 'Unlocked';
    } else if (isExpired) {
      badgeColor = const Color(0xFFFF6B6B);
      icon = Icons.lock_open;
      text = 'Ready';
    } else {
      // badgeColor = const Color(0xFFB8B1A2);
      badgeColor = AppTheme.charcoal;
      icon = Icons.lock;
      text = 'Locked';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
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

class _NoTimeCapsules extends StatefulWidget {
  @override
  State<_NoTimeCapsules> createState() => __NoTimeCapsulesState();
}

class __NoTimeCapsulesState extends State<_NoTimeCapsules>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    sin(_floatingController.value * 2 * pi) * 8,
                  ),
                  child: SizedBox(
                    height: 240,
                    width: 240,
                    child: Image.asset(
                      'assets/3d_icons/time.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'No Time Capsules Yet',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2A2A2A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first time capsule to save sats for your future self!',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF4B4B4B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Material(
              color: AppTheme.accentPink,
              borderRadius: BorderRadius.circular(15),
              elevation: 2,
              shadowColor: AppTheme.accentPink.withOpacity(0.3),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTimeCapsuleScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 24),

                      const SizedBox(width: 8),
                      Text(
                        'Create Time Capsule',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
