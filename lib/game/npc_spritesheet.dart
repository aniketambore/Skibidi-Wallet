import 'package:bonfire/bonfire.dart';

class NpcSpriteSheet {
  static Future<SpriteAnimation> skeletonIdleRight() => SpriteAnimation.load(
    'npc/skeleton.png',
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2(16, 22),
    ),
  );
}
