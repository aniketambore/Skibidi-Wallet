import 'package:bitwit_shit/game/custom_sprite_animation_widget.dart';
import 'package:bitwit_shit/game/functions.dart';
import 'package:bitwit_shit/game/npc_spritesheet.dart';
import 'package:bitwit_shit/game/player.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'enemy_spritesheet.dart';
import 'game.dart';
import 'game_spritesheet.dart';

class SwampyEnemy extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  final Vector2 initPosition;
  final Function() onShowMnemonic;
  double attack = 25;
  bool _isInDialog = false;
  bool _playerWasInVision = false;

  SwampyEnemy(this.initPosition, this.onShowMnemonic)
    : super(
        animation: SimpleDirectionAnimation(
          idleRight: EnemySpriteSheet.swampyRight(),
          runRight: EnemySpriteSheet.swampyRight(),
        ),
        position: initPosition,
        size: Vector2.all(tileSize * 0.8),
        speed: tileSize * 1.5,
        life: 120,
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(valueByTileSize(7), valueByTileSize(7)),
        position: Vector2(valueByTileSize(3), valueByTileSize(4)),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_playerWasInVision && !_isInDialog) {
      seePlayer(
        observed: (p) {
          _playerWasInVision = true;
          _showDialog();
        },
        radiusVision: tileSize * 3,
      );
    }

    if (!_isInDialog) {
      seeAndMoveToPlayer(
        radiusVision: tileSize * 3,
        closePlayer: (player) {
          execAttack();
        },
      );
    }
  }

  void _showDialog() {
    _isInDialog = true;
    if (gameRef.player != null) {
      gameRef.player!.idle();
    }

    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [
            TextSpan(text: "You want the magic words? Time to throw hands!"),
          ],
          person: CustomSpriteAnimationWidget(
            animation: EnemySpriteSheet.swampyRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onFinish: () {
        _isInDialog = false;
        // Sounds.interaction();
      },
    );
  }

  @override
  void onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: GameSpriteSheet.smokeExplosion(),
        position: position,
        size: Vector2(32, 32),
        loop: false,
      ),
    );
    removeFromParent();
    super.onDie();

    if (gameRef.player != null) {
      (gameRef.player as PlayerBob).receiveWordsFromSwampyEnemy();
    }

    startPostEnemyDialog(() {
      onShowMnemonic();
    });
  }

  void execAttack() {
    simpleAttackMelee(
      size: Vector2.all(tileSize * 0.62),
      damage: attack,
      interval: 800,
      animationRight: EnemySpriteSheet.enemyAttackEffectRight(),
      execute: () {
        // Sounds.attackEnemyMelee();
      },
    );
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
    super.onReceiveDamage(attacker, damage, id);
  }

  void startPostEnemyDialog(VoidCallback onFinish) {
    TalkDialog.show(
      gameRef.context,
      [
        (gameRef.player != null &&
                (gameRef.player as PlayerBob).hasCompleteMnemonics)
            ? Say(
              text: [
                TextSpan(
                  text:
                      "W! You got all 12. Now grab that key and unlock your future!",
                ),
              ],
              person: CustomSpriteAnimationWidget(
                animation: NpcSpriteSheet.skeletonIdleRight(),
              ),
              personSayDirection: PersonSayDirection.LEFT,
            )
            : Say(
              text: [
                TextSpan(
                  text:
                      "Bruh, you’re built different. Guard these words like your rarest meme!",
                ),
              ],
              person: CustomSpriteAnimationWidget(
                animation: NpcSpriteSheet.skeletonIdleRight(),
              ),
              personSayDirection: PersonSayDirection.LEFT,
            ),
      ],
      onFinish: () {
        onFinish();
      },
    );
  }
}
