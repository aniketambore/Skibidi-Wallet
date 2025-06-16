import 'package:bitwit_shit/bloc/account/account_cubit.dart';
import 'package:bitwit_shit/bloc/time_capsule/time_capsule_cubit.dart';
import 'package:bitwit_shit/dialogs/time_capsule_created_dialog.dart';
import 'package:bitwit_shit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CreateTimeCapsuleScreen extends StatefulWidget {
  const CreateTimeCapsuleScreen({super.key});

  @override
  State<CreateTimeCapsuleScreen> createState() =>
      _CreateTimeCapsuleScreenState();
}

class _CreateTimeCapsuleScreenState extends State<CreateTimeCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  // Predefined durations for quick selection
  final List<Duration> _quickDurations = [
    const Duration(days: 30), // 1 month
    const Duration(days: 90), // 3 months
    const Duration(days: 180), // 6 months
    const Duration(days: 365), // 1 year
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)), // 5 years max
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _setQuickDuration(Duration duration) {
    setState(() {
      _selectedDate = DateTime.now().add(duration);
    });
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    try {
      final amount = BigInt.parse(value);
      if (amount <= BigInt.zero) {
        return 'Amount must be greater than 0';
      }

      // Get total wallet balance
      final currentBalance =
          context.read<AccountCubit>().state.walletInfo?.balanceSat ??
          BigInt.zero;

      // Get locked balance from existing time capsules
      final lockedBalance = context
          .read<TimeCapsuleCubit>()
          .state
          .capsules
          .where((capsule) => !capsule.isUnlocked)
          .fold<BigInt>(BigInt.zero, (sum, capsule) => sum + capsule.amountSat);

      // Calculate spendable balance
      final spendableBalance = currentBalance - lockedBalance;

      if (amount > spendableBalance) {
        return 'Insufficient spendable balance. You have ${spendableBalance.toInt()} sats available';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }

    return null;
  }

  String? _validateDate() {
    if (_selectedDate == null) {
      return 'Please select an unlock date';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<TimeCapsuleCubit>().createCapsule(
        amountSat: BigInt.parse(_amountController.text),
        unlockDate: _selectedDate!,
        message: _messageController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        showTimeCapsuleCreatedDialog(
          context,
          amountSat: BigInt.parse(_amountController.text),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Create Time Capsule',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Amount Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (sats)',
                    hintText: 'Enter amount to lock',
                    prefixIcon: const Icon(Icons.currency_bitcoin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: GoogleFonts.inter(color: AppTheme.charcoal),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateAmount,
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 24),

              // Quick Duration Buttons
              Text(
                'Quick Select Duration',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _quickDurations.map((duration) {
                      return ActionChip(
                        label: Text(
                          _formatDuration(duration),
                          style: GoogleFonts.inter(color: AppTheme.charcoal),
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: AppTheme.charcoal.withOpacity(0.2),
                        ),
                        onPressed: () => _setQuickDuration(duration),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Date Selection
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(15),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Unlock Date',
                      hintText: 'Select when to unlock',
                      prefixIcon: const Icon(Icons.calendar_today),
                      errorText: _validateDate(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: GoogleFonts.inter(color: AppTheme.charcoal),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('MMMM d, y').format(_selectedDate!)
                          : 'Select a date',
                      style: GoogleFonts.inter(color: AppTheme.charcoal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Message Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Message to Future Self',
                    hintText: 'Write a note to your future self (optional)',
                    prefixIcon: const Icon(Icons.message),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: GoogleFonts.inter(color: AppTheme.charcoal),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Material(
                color: AppTheme.accentPink,
                borderRadius: BorderRadius.circular(15),
                elevation: 2,
                shadowColor: AppTheme.accentPink.withOpacity(0.3),
                child: InkWell(
                  onTap: _isSubmitting ? null : _submitForm,
                  borderRadius: BorderRadius.circular(15),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Center(
                      child:
                          _isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Create Time Capsule',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays >= 365) {
      return '${(duration.inDays / 365).floor()} year${duration.inDays >= 365 * 2 ? 's' : ''}';
    }
    if (duration.inDays >= 30) {
      return '${(duration.inDays / 30).floor()} month${duration.inDays >= 60 ? 's' : ''}';
    }
    return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
  }
}
