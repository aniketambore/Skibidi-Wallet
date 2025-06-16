import 'package:bitwit_shit/game/custom_sprite_animation_widget.dart';
import 'package:bitwit_shit/game/npc_spritesheet.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';

class SkeletonNpc extends SimpleNpc {
  bool _showConversation = false;

  SkeletonNpc(Vector2 position)
    : super(
        animation: SimpleDirectionAnimation(
          idleRight: NpcSpriteSheet.skeletonIdleRight(),
          runRight: NpcSpriteSheet.skeletonIdleRight(),
        ),
        position: position,
        size: Vector2(tileSize * 0.9, tileSize * 1.3),
        initDirection: Direction.left,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.6, size.y * 0.3), // Adjust as needed
        position: Vector2(size.x * 0.2, size.y * 0.4), // Adjust as needed
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: (player) {
          if (!_showConversation) {
            gameRef.player!.idle();
            _showConversation = true;
            // _showEmote(emote: 'emote/emote_interregacao.png');
            _showIntroduction();
          }
        },
        radiusVision: (1 * tileSize),
      );
    }
  }

  void _showIntroduction() {
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [
            TextSpan(
              text:
                  'Yo! Lost? You need a secret phrase—12 words. Until then, no key, no coins no cap.',
            ),
          ],
          person: CustomSpriteAnimationWidget(
            animation: NpcSpriteSheet.skeletonIdleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),

        Say(
          text: [
            TextSpan(
              text: 'Keep those words safe. Lose ‘em, lose everything. Fr fr.',
            ),
          ],
          person: CustomSpriteAnimationWidget(
            animation: NpcSpriteSheet.skeletonIdleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),

        Say(
          text: [
            TextSpan(
              text:
                  'Now go defeat those baddies and collect all 12. Only then you get the key!',
            ),
          ],
          person: CustomSpriteAnimationWidget(
            animation: NpcSpriteSheet.skeletonIdleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      logicalKeyboardKeysToNext: [LogicalKeyboardKey.space],
    );
  }

  @override
  bool debugMode = false;
}
