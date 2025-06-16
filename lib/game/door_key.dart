import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'game.dart';
import 'player.dart';

class DoorKey extends GameDecoration {
  final Function() onShowVerification;

  DoorKey(Vector2 position, this.onShowVerification)
    : super.withSprite(
        sprite: Sprite.load('items/key_silver.png'),
        position: position,
        size: Vector2(tileSize, tileSize),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.8, size.y * 0.8),
        position: Vector2(size.x * 0.1, size.y * 0.1),
      ),
    );
  }

  Widget _buildKeyWidget() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF787173), width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Sprite.load('items/key_silver.png').asWidget(),
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is PlayerBob) {
      if (other.hasCompleteMnemonics) {
        _showMnemonicVerification();
        // removeFromParent();
      } else {
        TalkDialog.show(gameRef.context, [
          Say(
            text: [
              TextSpan(
                text:
                    "Nah, chief. You need all 12 magic words before you can touch this key. No shortcuts!",
              ),
            ],
            person: _buildKeyWidget(),
            personSayDirection: PersonSayDirection.LEFT,
          ),
        ]);
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _showMnemonicVerification() {
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [
            TextSpan(
              text:
                  "You stacked all the words! Last step: prove you’re the real deal to grab the key",
            ),
          ],
          person: _buildKeyWidget(),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onClose: () {
        Future.delayed(Duration(milliseconds: 100), () {
          onShowVerification();
        });
      },
    );
  }

  @override
  bool get debugMode => false;
}
