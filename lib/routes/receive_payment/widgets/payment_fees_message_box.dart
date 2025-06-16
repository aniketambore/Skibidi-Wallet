import 'package:bitwit_shit/widgets/payment_info_message_box.dart';
import 'package:flutter/material.dart';

class PaymentFeesMessageBox extends StatelessWidget {
  final int feesSat;

  const PaymentFeesMessageBox({required this.feesSat, super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentInfoMessageBox(message: _formatFeesMessage(context, feesSat));
  }

  String _formatFeesMessage(BuildContext context, int feesSat) {
    if (feesSat == 0) {
      return 'Keep Skibidi open until the payment is completed.';
    }

    return 'A fee of $feesSat sats is applied to this invoice. Keep Skibidi open until the payment is completed.';
  }
}
