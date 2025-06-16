import 'dart:io';

import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BootstrapErrorPage extends StatefulWidget {
  const BootstrapErrorPage({
    super.key,
    required this.error,
    required this.stackTrace,
  });
  final Object error;
  final StackTrace stackTrace;

  @override
  State<BootstrapErrorPage> createState() => _BootstrapErrorPageState();
}

class _BootstrapErrorPageState extends State<BootstrapErrorPage> {
  final ScrollController _errorScrollController = ScrollController();
  final ScrollController _stackTraceScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        // TODO: Add Exit App Prompt
        exit(0);
      },
      child: MaterialApp(
        title: 'Skibidi Wallet',
        theme: AppTheme.lightTheme,
        builder: (BuildContext context, Widget? child) {
          const double kMaxTitleTextScaleFactor = 1.3;

          return MediaQuery.withClampedTextScaling(
            maxScaleFactor: kMaxTitleTextScaleFactor,
            child: child!,
          );
        },
        home: Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Error',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2A2A),
              ),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF6B6B).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Color(0xFFFF6B6B),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Oops! Something went wrong',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A2A2A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We encountered an error while starting the app',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B6B6B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Error Details',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2A2A2A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(
                              minHeight: 80,
                              maxHeight: 120,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE8E8E8),
                                width: 1,
                              ),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              trackVisibility: true,
                              controller: _errorScrollController,
                              child: SingleChildScrollView(
                                controller: _errorScrollController,
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  widget.error.toString(),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    color: const Color(0xFF6B6B6B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Stack Trace',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2A2A2A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(
                              minHeight: 160,
                              maxHeight: 240,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE8E8E8),
                                width: 1,
                              ),
                            ),
                            child: Scrollbar(
                              controller: _stackTraceScrollController,
                              child: SingleChildScrollView(
                                controller: _stackTraceScrollController,
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  widget.stackTrace.toString(),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    color: const Color(0xFF6B6B6B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8FB8)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => exit(1),
                        child: Text(
                          'EXIT APP',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
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
    );
  }
}
