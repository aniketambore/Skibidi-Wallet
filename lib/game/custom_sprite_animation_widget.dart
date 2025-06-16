import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class CustomSpriteAnimationWidget extends StatelessWidget {
  final Future<SpriteAnimation> animation;

  const CustomSpriteAnimationWidget({super.key, required this.animation});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 100, height: 100, child: animation.asWidget());
  }
}
