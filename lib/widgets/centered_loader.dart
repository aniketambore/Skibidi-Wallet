import 'package:flutter/material.dart';

import 'loader.dart';

class CenteredLoader extends StatelessWidget {
  final Color? color;
  const CenteredLoader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Center(
      child: Loader(
        color: color ?? themeData.primaryColor.withValues(alpha: .5),
      ),
    );
  }
}
