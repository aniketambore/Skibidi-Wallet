import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class ExternalBrowserService {
  static Future<void> launchLink(
    BuildContext context, {
    required String linkAddress,
  }) async {
    final Uri url = Uri.parse(linkAddress);
    if (!await launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }
}
