import 'package:bonfire/bonfire.dart';

class GameSpriteSheet {
  static Future<SpriteAnimation> smokeExplosion() => SpriteAnimation.load(
    'smoke_explosin.png',
    SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: 0.1,
      textureSize: Vector2(16, 16),
    ),
  );
}
