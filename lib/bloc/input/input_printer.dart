import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

extension InputTypeExtension on InputType {
  String toFormattedString() {
    return switch (this) {
      InputType_Bolt11() =>
        (this as InputType_Bolt11).invoice.toFormattedString(),
      _ => 'Unknown InputType',
    };
  }
}

extension LNInvoiceExtension on LNInvoice {
  String toFormattedString() =>
      'LNInvoice(invoice: $bolt11, paymentHash: $paymentHash, description: $description, '
      'amountMsat: $amountMsat, expiry: $expiry, payeePubkey: $payeePubkey, '
      'descriptionHash: $descriptionHash, timestamp: $timestamp, routingHints: $routingHints, '
      'paymentSecret: $paymentSecret)';
}
