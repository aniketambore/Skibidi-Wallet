import 'dart:math';
import 'package:bitwit_shit/theme/app_theme.dart'; // Assuming this is the correct path
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showMnemonicVerificationDialog(
  BuildContext context,
  List<int> wordPositions,
  List<String> correctWords,
  VoidCallback onSuccess,
  VoidCallback onRestart,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => MnemonicVerificationDialog(
          wordPositions: wordPositions,
          correctWords: correctWords,
          onSuccess: onSuccess,
          onRestart: onRestart,
        ),
  );
}

class MnemonicVerificationDialog extends StatefulWidget {
  final List<int> wordPositions; // e.g., [2, 5, 8] for words to verify
  final List<String> correctWords; // The correct words for verification
  final VoidCallback onSuccess;
  final VoidCallback onRestart;

  const MnemonicVerificationDialog({
    super.key,
    required this.wordPositions,
    required this.correctWords,
    required this.onSuccess,
    required this.onRestart,
  }) : assert(
         wordPositions.length == correctWords.length,
         'wordPositions and correctWords must have the same length',
       );

  @override
  State<MnemonicVerificationDialog> createState() =>
      _MnemonicVerificationDialogState();
}

class _MnemonicVerificationDialogState extends State<MnemonicVerificationDialog>
    with SingleTickerProviderStateMixin {
  int _currentWordIndex = 0;
  List<String> _enteredLetters = [];
  List<String> _letterChoices = [];
  String _feedbackMessage = '';
  bool _isChecking = false;

  late AnimationController _feedbackAnimationController;
  late Animation<Offset> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _setupCurrentWord();

    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _feedbackAnimationController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    super.dispose();
  }

  void _setupCurrentWord() {
    setState(() {
      _enteredLetters = [];
      _feedbackMessage = '';
      String currentTargetWord =
          widget.correctWords[_currentWordIndex].toLowerCase();
      _letterChoices = _generateLetterChoices(currentTargetWord);
    });
  }

  List<String> _generateLetterChoices(String targetWord) {
    List<String> choices = targetWord.split('');
    Random random = Random();
    List<String> alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');
    int distractorsNeeded = max(0, 12 - choices.length);

    for (int i = 0; i < distractorsNeeded; i++) {
      String distractor;
      do {
        distractor = alphabet[random.nextInt(alphabet.length)];
      } while (choices.contains(distractor));
      choices.add(distractor);
    }
    choices.shuffle();
    return choices;
  }

  void _onLetterTap(String letter) {
    if (_isChecking) return;
    String currentTargetWord =
        widget.correctWords[_currentWordIndex].toLowerCase();
    if (_enteredLetters.length < currentTargetWord.length) {
      setState(() {
        _enteredLetters.add(letter);
        _feedbackMessage = '';
      });
    }
  }

  void _onBackspaceTap() {
    if (_isChecking) return;
    if (_enteredLetters.isNotEmpty) {
      setState(() {
        _enteredLetters.removeLast();
        _feedbackMessage = '';
      });
    }
  }

  void _onSubmit() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
      _feedbackMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 300));

    String enteredWord = _enteredLetters.join('');
    String correctWord = widget.correctWords[_currentWordIndex].toLowerCase();

    if (enteredWord == correctWord) {
      if (_currentWordIndex < widget.correctWords.length - 1) {
        setState(() {
          _currentWordIndex++;
          _isChecking = false;
        });
        _setupCurrentWord();
      } else {
        widget.onSuccess();
      }
    } else {
      setState(() {
        _feedbackMessage = 'Incorrect. Try again, fam!';
        _isChecking = false;
      });
      _feedbackAnimationController.forward(from: 0.0).then((_) {
        if (mounted) {
          _feedbackAnimationController.reverse();
        }
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted && _feedbackMessage.isNotEmpty) {
        setState(() {
          _enteredLetters = [];
          _feedbackMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentTargetWord =
        widget.correctWords[_currentWordIndex].toLowerCase();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryWhite, // Main background
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: AppTheme.charcoal.withValues(
                  alpha: 0.08,
                ), // Softer shadow
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(), // Removed theme pass-through, using AppTheme directly
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWordProgressIndicator(),
                    const SizedBox(height: 24),
                    _buildWordDisplay(currentTargetWord),
                    const SizedBox(height: 8),
                    if (_feedbackMessage.isNotEmpty)
                      SlideTransition(
                        position: _feedbackAnimation,
                        child: Text(
                          _feedbackMessage,
                          style: GoogleFonts.inter(
                            color: AppTheme.accentPink, // Keep pink for errors
                            fontWeight:
                                FontWeight.w600, // Slightly bolder error
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildLetterGrid(),
                    const SizedBox(height: 24),
                    _buildActionButtons(currentTargetWord.length),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: const BoxDecoration(
        color: AppTheme.softBlue, // Changed header background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Verify Word #${widget.wordPositions[_currentWordIndex]}',
            style: GoogleFonts.poppins(
              color: AppTheme.primaryWhite, // Changed header text color
              fontSize: 18,
              fontWeight: FontWeight.w700, // Bolder header text
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppTheme.primaryWhite,
            ), // Changed icon color
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildWordProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.correctWords.length, (index) {
        Color progressColor;
        if (index == _currentWordIndex) {
          progressColor = AppTheme.accentPink; // Current word indicator
        } else if (index < _currentWordIndex) {
          progressColor = AppTheme.bitcoinGold; // Completed words
        } else {
          progressColor = AppTheme.mediumGray; // Pending words
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }

  Widget _buildWordDisplay(String targetWord) {
    List<Widget> displayLetters = [];
    for (int i = 0; i < targetWord.length; i++) {
      String letter = '';
      if (i < _enteredLetters.length) {
        letter = _enteredLetters[i];
      }
      displayLetters.add(
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 3.0,
          ), // Slightly less margin
          width: 38, // Slightly smaller
          height: 48, // Slightly smaller
          decoration: BoxDecoration(
            color: AppTheme.primaryWhite, // Cleaner background for slots
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: AppTheme.softBlue.withOpacity(
                0.7,
              ), // Border color from header
              width: 1.5, // Slightly thicker border
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.softBlue.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            letter.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 20, // Slightly smaller font for slots
              fontWeight: FontWeight.w700, // Bolder letters in slots
              color: AppTheme.charcoal,
            ),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4.0, // Spacing between items in a run
      runSpacing: 4.0, // Spacing between runs
      children: displayLetters,
    );
  }

  Widget _buildLetterGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _letterChoices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final letter = _letterChoices[index];
        return Material(
          color: AppTheme.softGray.withOpacity(0.7), // Lighter tile background
          borderRadius: BorderRadius.circular(10.0), // More rounded tiles
          elevation: 0.5, // Softer elevation
          shadowColor: AppTheme.charcoal.withOpacity(0.05),
          child: InkWell(
            onTap: () => _onLetterTap(letter),
            borderRadius: BorderRadius.circular(10.0),
            splashColor: AppTheme.softBlue.withOpacity(0.2),
            highlightColor: AppTheme.softBlue.withOpacity(0.1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppTheme.mediumGray.withOpacity(0.5)),
              ),
              alignment: Alignment.center,
              child: Text(
                letter.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 16, // Slightly smaller tile font
                  fontWeight: FontWeight.w600, // Bolder tile letters
                  color: AppTheme.charcoal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(int targetWordLength) {
    bool canSubmit = _enteredLetters.length == targetWordLength;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: widget.onRestart,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            'Restart Game', // Changed text
            style: GoogleFonts.inter(
              color: AppTheme.mediumGray,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.backspace_rounded, // Changed icon
                color: AppTheme.darkGray.withOpacity(0.8),
              ),
              onPressed: _onBackspaceTap,
              iconSize: 26, // Slightly smaller
              splashRadius: 20,
            ),
            const SizedBox(width: 12), // Reduced spacing
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canSubmit
                        ? AppTheme.accentPink
                        : AppTheme.lightGray.withOpacity(
                          0.8,
                        ), // Changed active button color
                foregroundColor:
                    canSubmit
                        ? AppTheme.primaryWhite
                        : AppTheme.mediumGray, // Text color
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, // Reduced padding
                  vertical: 10, // Reduced padding
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: canSubmit ? 3 : 1,
                shadowColor:
                    canSubmit
                        ? AppTheme.accentPink.withOpacity(0.3)
                        : Colors.transparent,
              ),
              onPressed: (canSubmit && !_isChecking) ? _onSubmit : null,
              child:
                  _isChecking
                      ? const SizedBox(
                        width: 18, // Smaller loader
                        height: 18, // Smaller loader
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryWhite,
                          ),
                        ),
                      )
                      : Text(
                        _currentWordIndex < widget.correctWords.length - 1
                            ? 'Next Word'
                            : 'Verify Now', // Changed text
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, // Bolder button text
                          fontSize: 14, // Slightly smaller button text
                        ),
                      ),
            ),
          ],
        ),
      ],
    );
  }
}
