import 'package:bitwit_shit/utils/exceptions/exception_handler.dart';
import 'package:bitwit_shit/utils/mnemonic_utils.dart';
import 'package:flutter/material.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'restore_form.dart';

class RestoreFormContent extends StatefulWidget {
  const RestoreFormContent({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.changePage,
    required this.textEditingControllers,
    this.lastErrorMessage = '',
    this.initialWords = const <String>[],
  });

  final int currentPage;
  final int lastPage;
  final VoidCallback changePage;
  final List<String> initialWords;
  final String lastErrorMessage;
  final List<TextEditingController> textEditingControllers;

  @override
  State<RestoreFormContent> createState() => _RestoreFormContentState();
}

class _RestoreFormContentState extends State<RestoreFormContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AutovalidateMode _autoValidateMode;
  late bool _hasError;

  @override
  void initState() {
    super.initState();
    _autoValidateMode = AutovalidateMode.disabled;
    _hasError = false;
    MnemonicUtils.tryPopulateTextFieldsFromText(
      widget.initialWords.join(' '),
      widget.textEditingControllers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RestoreForm(
          formKey: _formKey,
          currentPage: widget.currentPage,
          lastPage: widget.lastPage,
          textEditingControllers: widget.textEditingControllers,
          autoValidateMode: _autoValidateMode,
        ),
        const SizedBox(height: 18),
        if ((_hasError || widget.lastErrorMessage.isNotEmpty) &&
            widget.currentPage == 2) ...<Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentPink.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.accentPink,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Failed to restore from backup. Please make sure backup phrase was correctly entered and try again',
                    style: GoogleFonts.inter(
                      color: AppTheme.accentPink,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softBlue,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(
              widget.currentPage + 1 == (widget.lastPage + 1)
                  ? 'Restore'
                  : 'Next',
            ),
            onPressed: () {
              setState(() {
                _hasError = false;
                if (_formKey.currentState!.validate() && !_hasError) {
                  _autoValidateMode = AutovalidateMode.disabled;
                  if (widget.currentPage + 1 == (widget.lastPage + 1)) {
                    _validateMnemonics();
                  } else {
                    widget.changePage();
                  }
                } else {
                  _autoValidateMode = AutovalidateMode.always;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _validateMnemonics() async {
    final String mnemonic = widget.textEditingControllers
        .map(
          (TextEditingController controller) =>
              controller.text.toLowerCase().trim(),
        )
        .toList()
        .join(' ');
    try {
      Navigator.pop(context, mnemonic);
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      throw Exception(ExceptionHandler.extractMessage(e));
    }
  }
}
