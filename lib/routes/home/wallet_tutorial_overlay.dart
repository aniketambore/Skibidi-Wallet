import 'package:flutter/material.dart';

class WalletTutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const WalletTutorialOverlay({super.key, required this.onDismiss});

  @override
  State<WalletTutorialOverlay> createState() => _WalletTutorialOverlayState();
}

class _WalletTutorialOverlayState extends State<WalletTutorialOverlay> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: "Welcome to Your Bitcoin Wallet!",
      description:
          "Let's learn how to use your wallet. Tap 'Next' to continue.",
      position: TutorialPosition.center,
    ),
    TutorialStep(
      title: "View Your Balance",
      description: "Double tap on the card to see your current balance",
      position: TutorialPosition.center,
    ),
    TutorialStep(
      title: "Send Bitcoin",
      description: "Swipe left to send Bitcoin to others",
      position: TutorialPosition.left,
    ),
    TutorialStep(
      title: "Receive Bitcoin",
      description: "Swipe right to receive Bitcoin from others",
      position: TutorialPosition.right,
    ),
    TutorialStep(
      title: "View Transactions",
      description: "Swipe up to see your transaction history",
      position: TutorialPosition.bottom,
    ),
    TutorialStep(
      title: "Wallet Tools",
      description: "Long press on the card to access wallet tools",
      position: TutorialPosition.center,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onDismiss();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStep];

    return Stack(
      children: [
        // Semi-transparent background
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),

        // Tutorial content
        Positioned(
          top: _getTopPosition(currentStep.position),
          left: 0,
          right: 0,
          child: Column(
            children: [
              _buildTutorialContent(currentStep),
              const SizedBox(height: 20),
              _buildNavigationButtons(),
            ],
          ),
        ),

        // Progress indicator
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _steps.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index == _currentStep
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getTopPosition(TutorialPosition position) {
    switch (position) {
      case TutorialPosition.top:
        return MediaQuery.of(context).size.height * 0.2;
      case TutorialPosition.center:
        return MediaQuery.of(context).size.height * 0.4;
      case TutorialPosition.bottom:
        return MediaQuery.of(context).size.height * 0.6;
      case TutorialPosition.left:
        return MediaQuery.of(context).size.height * 0.4;
      case TutorialPosition.right:
        return MediaQuery.of(context).size.height * 0.4;
    }
  }

  Widget _buildTutorialContent(TutorialStep step) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            step.description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          if (step.position == TutorialPosition.left)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Icon(Icons.swipe_left, size: 32, color: Colors.black54),
            )
          else if (step.position == TutorialPosition.right)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Icon(Icons.swipe_right, size: 32, color: Colors.black54),
            )
          else if (step.position == TutorialPosition.bottom)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Icon(Icons.swipe_up, size: 32, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentStep > 0)
          TextButton(
            onPressed: _previousStep,
            child: const Text(
              "Previous",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        const SizedBox(width: 20),
        TextButton(
          onPressed: _nextStep,
          child: Text(
            _currentStep == _steps.length - 1 ? "Got it" : "Next",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

enum TutorialPosition { top, center, bottom, left, right }

class TutorialStep {
  final String title;
  final String description;
  final TutorialPosition position;

  TutorialStep({
    required this.title,
    required this.description,
    required this.position,
  });
}
