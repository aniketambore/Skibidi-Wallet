import 'package:bitwit_shit/bloc/payments/models/payment_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitwit_shit/bloc/payments/payments_cubit.dart';
import 'package:bitwit_shit/bloc/payments/payments_state.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:timeago/timeago.dart' as timeago;

class TransactionHistorySheet extends StatelessWidget {
  final ScrollController scrollController;

  const TransactionHistorySheet({super.key, required this.scrollController});

  String _formatDateTime(DateTime dateTime) {
    return timeago.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6E3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFB8B1A2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Transaction History',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2A2A),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PaymentsCubit, PaymentsState>(
              builder: (context, state) {
                final List<PaymentData> transactions = state.filteredPayments;

                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF4B4B4B),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  transaction.paymentType == PaymentType.send
                                      ? const Color(0xFFFFE5E5)
                                      : const Color(0xFFE5FFE5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              transaction.paymentType == PaymentType.send
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color:
                                  transaction.paymentType == PaymentType.send
                                      ? const Color(0xFFFF4444)
                                      : const Color(0xFF44FF44),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.paymentType == PaymentType.send
                                      ? 'Sent'
                                      : 'Received',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2A2A2A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₿ ${transaction.amountSat}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF4B4B4B),
                                  ),
                                ),
                                if (transaction.feeSat > 0) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Fee: ₿ ${transaction.feeSat}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(
                                        0xFF4B4B4B,
                                      ).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            _formatDateTime(transaction.paymentTime),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF4B4B4B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
