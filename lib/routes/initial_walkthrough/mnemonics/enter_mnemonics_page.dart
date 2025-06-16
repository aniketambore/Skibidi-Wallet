import 'package:flutter/material.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'restore_form_content.dart';

class EnterMnemonicsPage extends StatefulWidget {
  const EnterMnemonicsPage({
    super.key,
    required this.initialWords,
    this.errorMessage = '',
  });

  final List<String> initialWords;
  final String errorMessage;

  @override
  State<EnterMnemonicsPage> createState() => _EnterMnemonicsPageState();
}

class _EnterMnemonicsPageState extends State<EnterMnemonicsPage> {
  int _currentPage = 1;
  final int _lastPage = 2;

  List<TextEditingController> textEditingControllers =
      List<TextEditingController>.generate(12, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _currentPage = widget.errorMessage.isNotEmpty ? 2 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData query = MediaQuery.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5), Color(0xFFE3F0FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: AppTheme.charcoal,
            onPressed: () {
              if (_currentPage == 1) {
                Navigator.pop(context);
              } else if (_currentPage > 1) {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  _currentPage--;
                });
              }
            },
          ),
          title: Row(
            children: [
              Text(
                'Restore Wallet',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoal,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Step $_currentPage/$_lastPage',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.softBlue,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.softBlue.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.lightGray.withOpacity(0.5),
                  ),
                ),
                child: RestoreFormContent(
                  currentPage: _currentPage,
                  lastPage: _lastPage,
                  initialWords: widget.initialWords,
                  lastErrorMessage: widget.errorMessage,
                  textEditingControllers: textEditingControllers,
                  changePage: () {
                    setState(() {
                      _currentPage++;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
