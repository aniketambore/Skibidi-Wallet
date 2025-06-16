import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitwit_shit/bloc/account/account_cubit.dart';
import 'package:bitwit_shit/bloc/account/account_state.dart';
import 'package:bitwit_shit/utils/bitcoin_legends.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BitcoinLegendMapScreen extends StatelessWidget {
  const BitcoinLegendMapScreen({super.key});

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
            'Bitcoin Level Map',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<AccountCubit, AccountState>(
                builder: (context, accountState) {
                  final balance =
                      accountState.walletInfo?.balanceSat.toInt() ?? 0;
                  return _buildMap(context, balance);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, int balance) {
    final legends = [
      {'type': BitcoinLegendType.skibidiBob, 'threshold': 0, 'title': 'Newbie'},
      {
        'type': BitcoinLegendType.skibidiJackDorsey,
        'threshold': 500,
        'title': 'Visionary',
      },
      {
        'type': BitcoinLegendType.skibidiSuperTestnet,
        'threshold': 1000,
        'title': 'Hacker',
      },
      {
        'type': BitcoinLegendType.skibidiUncleRockstarDev,
        'threshold': 10000,
        'title': 'Rockstar',
      },
      {
        'type': BitcoinLegendType.skibidiLuke,
        'threshold': 20000,
        'title': 'Core OG',
      },
      {
        'type': BitcoinLegendType.skibidiJimmySong,
        'threshold': 5000,
        'title': 'Cowboy',
      },
      {
        'type': BitcoinLegendType.skibidiTadgeDryja,
        'threshold': 50000,
        'title': 'Lightning OG',
      },
      {
        'type': BitcoinLegendType.skibidiJosephPoon,
        'threshold': 100000,
        'title': 'Trailblazer',
      },
      {
        'type': BitcoinLegendType.skibidiAndreasAntonopoulos,
        'threshold': 200000,
        'title': 'Sensei',
      },
      {
        'type': BitcoinLegendType.skibidiPieterWuille,
        'threshold': 500000,
        'title': 'Wizard',
      },
      {
        'type': BitcoinLegendType.skibidiNickSzabo,
        'threshold': 1000000,
        'title': 'Architect',
      },
      {
        'type': BitcoinLegendType.skibidiHalFinney,
        'threshold': 2000000,
        'title': 'Legend',
      },
      {
        'type': BitcoinLegendType.skibidiAdamBack,
        'threshold': 5000000,
        'title': 'Cyberpunk',
      },
      {
        'type': BitcoinLegendType.skibidiSatoshi,
        'threshold': 10000000,
        'title': 'OG',
      },
    ];

    // Sort legends by threshold
    legends.sort(
      (a, b) => (a['threshold'] as int).compareTo(b['threshold'] as int),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProgressIndicator(balance, legends),
            const SizedBox(height: 24),
            _buildLegendCards(legends, balance),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    int balance,
    List<Map<String, dynamic>> legends,
  ) {
    // Find current level and next level
    int currentLevelIndex = 0;
    for (int i = legends.length - 1; i >= 0; i--) {
      if (balance >= legends[i]['threshold']!) {
        currentLevelIndex = i;
        break;
      }
    }

    final currentLegend = legends[currentLevelIndex];
    final nextLegend =
        currentLevelIndex < legends.length - 1
            ? legends[currentLevelIndex + 1]
            : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Level: ${currentLegend['title']}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 16),
          if (nextLegend != null) ...[
            LinearProgressIndicator(
              value:
                  (balance - currentLegend['threshold']!) /
                  (nextLegend['threshold']! - currentLegend['threshold']!),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6B9EFF),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Next Level: ${nextLegend['title']} (${(nextLegend['threshold']! - balance)} sats to go)',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ] else
            Text(
              'Maximum Level Achieved! 🎉',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendCards(List<Map<String, dynamic>> legends, int balance) {
    final currentLevelIndex = _getCurrentLevelIndex(balance, legends);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: legends.length,
      itemBuilder: (context, index) {
        final legend = legends[index];
        final isUnlocked = balance >= legend['threshold']!;
        final isCurrentLevel = index == currentLevelIndex;
        final legendData = BitcoinLegend.fromType(
          legend['type'] as BitcoinLegendType,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 50,
                height: 50,
                child:
                    isCurrentLevel
                        ? _buildLegendImage(legendData.image, true)
                        : _buildBlurredPlaceholder(legendData.name),
              ),
            ),
            title: Text(
              legendData.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? const Color(0xFF2A2A2A) : Colors.grey[400],
              ),
            ),
            subtitle: Text(
              '${legend['title']} • ${legend['threshold']} sats',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            trailing: Icon(
              isUnlocked ? Icons.check_circle : Icons.lock,
              color: isUnlocked ? const Color(0xFF4CAF50) : Colors.grey[400],
            ),
          ),
        );
      },
    );
  }

  int _getCurrentLevelIndex(int balance, List<Map<String, dynamic>> legends) {
    for (int i = legends.length - 1; i >= 0; i--) {
      if (balance >= legends[i]['threshold']!) {
        return i;
      }
    }
    return 0;
  }

  Widget _buildBlurredPlaceholder(String legendName) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          legendName.split(' ').map((word) => word[0]).join(''),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendImage(String imagePath, bool isUnlocked) {
    Widget imageWidget;

    if (imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
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
      imageWidget = CachedNetworkImage(
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

    return imageWidget;
  }
}
