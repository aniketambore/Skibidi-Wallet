import 'package:bitwit_shit/game/functions.dart';
import 'package:bitwit_shit/game/game.dart';
import 'package:bitwit_shit/game/player_spritesheet.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async' as async;

class PlayerBob extends SimplePlayer with BlockMovementCollision {
  double attack = 25;
  double stamina = 100;
  async.Timer? _timerStamina;
  bool showObserveEnemy = false;
  bool hasFirstSixWords = false;
  bool hasAllTwelveWords = false;
  bool _muddyEnemyKilled = false;
  bool _swampyEnemyKilled = false;

  PlayerBob(Vector2 position)
    : super(
        size: Vector2(16 * 1.8, 32 * 1.8),
        position: position,
        life: 200,
        speed: tileSize * 2.5,
        initDirection: Direction.down,
      ) {
    setupMovementByJoystick(intensityEnabled: true);
  }

  @override
  Future<void> onLoad() async {
    animation = await PlayerBobSpriteSheet.simpleDirectionAnimation();
    add(
      RectangleHitbox(
        size: Vector2(
          size.x * 0.5,
          size.y * 0.5,
        ), // 50% of player size, adjust as needed
        position: Vector2(
          size.x * 0.25,
          size.y * 0.5,
        ), // Centered horizontally, lower half
      ),
    );
    return super.onLoad();
  }

  @override
  bool get debugMode => false;

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == LogicalKeyboardKey.space &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    super.onJoystickAction(event);
  }

  void actionAttack() {
    if (stamina < 15) {
      return;
    }

    // Sounds.attackPlayerMelee();
    decrementStamina(15);
    _addAttackAnimation();
    simpleAttackMelee(
      damage: attack,
      animationRight: PlayerBobSpriteSheet.attackEffectRight(),
      size: Vector2.all(tileSize),
    );
  }

  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  void _addAttackAnimation() {
    Future<SpriteAnimation> newAnimation = PlayerBobSpriteSheet.playerSitRight;
    switch (lastDirection) {
      case Direction.right:
        newAnimation = PlayerBobSpriteSheet.playerSitRight;
        break;
      case Direction.left:
        newAnimation = PlayerBobSpriteSheet.playerSitLeft;
        break;
      default:
    }
    animation?.playOnce(newAnimation, useCompFlip: true);
  }

  @override
  void onDie() {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: Vector2(position.x, position.y),
        size: Vector2.all(30),
      ),
    );
    super.onDie();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _verifyStamina();
    seeEnemy(
      radiusVision: tileSize * 6,
      notObserved: () {
        showObserveEnemy = false;
      },
      observed: (enemies) {
        if (showObserveEnemy) return;
        showObserveEnemy = true;
        // _showEmote();
      },
    );
    super.update(dt);
  }

  void _verifyStamina() {
    if (_timerStamina == null) {
      _timerStamina = async.Timer(Duration(milliseconds: 150), () {
        _timerStamina = null;
      });
    } else {
      return;
    }

    stamina += 2;
    if (stamina > 100) {
      stamina = 100;
    }
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    showDamage(
      damage,
      config: TextStyle(fontSize: valueByTileSize(5), color: Colors.orange),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void receiveWordsFromMuddyEnemy() {
    if (!_muddyEnemyKilled && !_swampyEnemyKilled) {
      // MuddyEnemy was killed first
      hasFirstSixWords = true;
      _muddyEnemyKilled = true;
    } else if (_swampyEnemyKilled && !_muddyEnemyKilled) {
      // SwampyEnemy was killed first, so MuddyEnemy gives last 6 words
      hasAllTwelveWords = true;
      _muddyEnemyKilled = true;
    }
  }

  void receiveWordsFromSwampyEnemy() {
    if (!_swampyEnemyKilled && !_muddyEnemyKilled) {
      // SwampyEnemy was killed first
      hasFirstSixWords = true;
      _swampyEnemyKilled = true;
    } else if (_muddyEnemyKilled && !_swampyEnemyKilled) {
      // MuddyEnemy was killed first, so SwampyEnemy gives last 6 words
      hasAllTwelveWords = true;
      _swampyEnemyKilled = true;
    }
  }

  bool get hasCompleteMnemonics => hasAllTwelveWords;
  bool get hasPartialMnemonics => hasFirstSixWords;
  bool get muddyEnemyKilled => _muddyEnemyKilled;
  bool get swampyEnemyKilled => _swampyEnemyKilled;
}
