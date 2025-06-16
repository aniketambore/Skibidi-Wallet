import 'package:bonfire/bonfire.dart';

class PlayerBobSpriteSheet {
  static const double stepTime = 0.1;

  static Future<SimpleDirectionAnimation> simpleDirectionAnimation() async {
    final idle = await Flame.images.load('player/player_idle.png');
    final run = await Flame.images.load('player/player_run.png');

    return SimpleDirectionAnimation(
      idleRight: idle.getAnimation(
        size: Vector2(16, 32),
        amount: 3,
        stepTime: stepTime,
        position: Vector2(0, 0),
      ),
      idleUp: idle.getAnimation(
        size: Vector2(16, 32),
        amount: 6,
        stepTime: stepTime,
        position: Vector2(16 * 6, 0), // Start at frame 6 (up)
      ),
      idleLeft: idle.getAnimation(
        size: Vector2(16, 32),
        amount: 6,
        stepTime: stepTime,
        position: Vector2(16 * 12, 0), // Start at frame 12 (left)
      ),
      idleDown: idle.getAnimation(
        size: Vector2(16, 32),
        amount: 6,
        stepTime: stepTime,
        position: Vector2(16 * 18, 0), // Start at frame 18 (down)
      ),
      runRight: run.getAnimation(
        size: Vector2(16, 32),
        amount: 6,
        stepTime: stepTime,
        position: Vector2(0, 0),
      ),
      runUp: run.getAnimation(
        size: Vector2(16, 32),
        amount: 6,
        stepTime: stepTime,
        position: Vector2(16 * 6, 0),
      ),
      runLeft: run.getAnimation(
        size: Vector2(16, 32),
        amount: 6,
        stepTime: stepTime,
        position: Vector2(16 * 12, 0),
      ),
      runDown: run.getAnimation(
        size: Vector2(16, 32),
        amount: 6,
        stepTime: stepTime,
        position: Vector2(16 * 18, 0),
      ),
    );
  }

  static Future<SpriteAnimation> attackEffectRight() => SpriteAnimation.load(
    'player/attack_effect_right.png',
    SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: 0.1,
      textureSize: Vector2(16, 16),
    ),
  );

  static Future<SpriteAnimation> get playerSitRight => Flame.images
      .load('player/player_sit.png')
      .then(
        (image) => image.getAnimation(
          size: Vector2(16, 32),
          amount: 6,
          stepTime: stepTime,
          loop: false,
          position: Vector2(0, 0),
        ),
      );

  static Future<SpriteAnimation> get playerSitLeft => Flame.images
      .load('player/player_sit.png')
      .then(
        (image) => image.getAnimation(
          size: Vector2(16, 32),
          amount: 6,
          stepTime: stepTime,
          loop: false,
          position: Vector2(16 * 6, 0),
        ),
      );
}
