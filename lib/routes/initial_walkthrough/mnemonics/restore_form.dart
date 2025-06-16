import 'dart:async';

import 'package:bitwit_shit/utils/mnemonic_utils.dart';
import 'package:bitwit_shit/utils/wordlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RestoreForm extends StatefulWidget {
  const RestoreForm({
    super.key,
    required this.formKey,
    required this.currentPage,
    required this.lastPage,
    required this.textEditingControllers,
    required this.autoValidateMode,
  });

  final GlobalKey formKey;
  final int currentPage;
  final int lastPage;
  final List<TextEditingController> textEditingControllers;
  final AutovalidateMode autoValidateMode;

  @override
  State<RestoreForm> createState() => _RestoreFormState();
}

class _RestoreFormState extends State<RestoreForm> {
  List<FocusNode> focusNodes = List<FocusNode>.generate(12, (_) => FocusNode());

  late AutovalidateMode _autoValidateMode;

  @override
  void initState() {
    super.initState();
    _autoValidateMode = AutovalidateMode.disabled;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List<Widget>.generate(6, (int index) {
            final int itemIndex = index + (6 * (widget.currentPage - 1));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.softBlue.withOpacity(0.25),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${itemIndex + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.softBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TypeAheadFormField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        autocorrect: false,
                        controller: widget.textEditingControllers[itemIndex],
                        textInputAction: TextInputAction.next,
                        onSubmitted: (String text) async {
                          final List<String> suggestions =
                              await _getSuggestions(text);
                          widget.textEditingControllers[itemIndex].text =
                              suggestions.length == 1
                                  ? suggestions.first
                                  : text;
                          if (itemIndex + 1 < focusNodes.length) {
                            focusNodes[itemIndex + 1].requestFocus();
                          }
                        },
                        focusNode: focusNodes[itemIndex],
                        decoration: InputDecoration(
                          labelText: 'Word',
                          hintText: 'Enter word',
                          filled: true,
                          fillColor: AppTheme.softGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.lightGray,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.lightGray,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.softBlue,
                              width: 2,
                            ),
                          ),
                          labelStyle: GoogleFonts.inter(
                            color: AppTheme.darkGray,
                            fontWeight: FontWeight.w400,
                          ),
                          hintStyle: GoogleFonts.inter(
                            color: AppTheme.mediumGray,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: _processPotentialBackupPhrase,
                      ),
                      autovalidateMode: _autoValidateMode,
                      validator: (String? text) => _onValidate(context, text!),
                      suggestionsCallback: _getSuggestions,
                      hideOnEmpty: true,
                      hideOnLoading: true,
                      autoFlipDirection: true,
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 6,
                        constraints: const BoxConstraints(
                          minWidth: 180,
                          maxWidth: 260,
                          maxHeight: 180,
                        ),
                        shadowColor: AppTheme.softBlue.withOpacity(0.12),
                      ),
                      itemBuilder: <BuildContext, String>(
                        BuildContext context,
                        dynamic suggestion,
                      ) {
                        return ListTile(
                          title: Text(
                            suggestion,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppTheme.charcoal,
                            ),
                          ),
                        );
                      },
                      onSuggestionSelected: <String>(dynamic suggestion) {
                        widget.textEditingControllers[itemIndex].text =
                            suggestion;
                        if (itemIndex + 1 < focusNodes.length) {
                          focusNodes[itemIndex + 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  String? _onValidate(BuildContext context, String text) {
    if (text.isEmpty) {
      return 'Missing word';
    }
    if (!wordlist.contains(text.toLowerCase().trim())) {
      return 'Invalid word';
    }
    return null;
  }

  FutureOr<List<String>> _getSuggestions(String pattern) {
    if (pattern.toString().isEmpty) {
      return List<String>.empty();
    } else {
      final List<String> suggestionList =
          wordlist.where((String item) => item.startsWith(pattern)).toList();
      return suggestionList.isNotEmpty ? suggestionList : List<String>.empty();
    }
  }

  void _processPotentialBackupPhrase(String? backupPhrase) {
    MnemonicUtils.tryPopulateTextFieldsFromText(
      backupPhrase,
      widget.textEditingControllers,
    );
  }
}
