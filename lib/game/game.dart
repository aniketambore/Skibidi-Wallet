import 'dart:math';
import 'package:bitwit_shit/services/injector.dart';
import 'package:logging/logging.dart';
import 'package:bitwit_shit/dialogs/mnemonic_verification_dialog.dart';
import 'package:bitwit_shit/game/player.dart';
import 'package:bitwit_shit/game/skeletel_npc.dart';
import 'package:bitwit_shit/game/swampy_enemy.dart';
import 'package:bitwit_shit/screens/victory_transition_screen.dart';
import 'package:bitwit_shit/services/audio_service.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bitwit_shit/dialogs/mnemonic_reveal_dialog.dart';
import 'package:bitwit_shit/dialogs/game_over_dialog.dart';

import 'door_key.dart';
import 'game_interface.dart';
import 'muddy_enemy.dart';

const tileSize = 32.0;

final _log = Logger('GameController');

class GameController extends GameComponent {
  bool _showMnemonicDialog = false;
  List<String>? _pendingMnemonic;
  bool _isFirstHalf = true;
  bool showGameOver = false;
  final AudioService _audioService;
  bool _hasKilledFirstEnemy = false;

  GameController(this._audioService);

  final _random = Random(); // For selecting random words

  Future<void> showMnemonicAfterEnemyDefeat(bool isFirstHalf) async {
    final String? accountMnemonic =
        await ServiceInjector().credentialsManager.restoreMnemonic();
    if (accountMnemonic == null) {
      _log.severe('Failed to get mnemonic from credentials manager');
      return;
    }

    final List<String> mnemonicWords = accountMnemonic.split(' ');

    // If this is the first enemy killed
    if (!_hasKilledFirstEnemy) {
      _pendingMnemonic = mnemonicWords.sublist(0, 6);
      _showMnemonicDialog = true;
      _hasKilledFirstEnemy = true;
    }
    // If this is the second enemy killed
    else if (_hasKilledFirstEnemy) {
      _pendingMnemonic = mnemonicWords.sublist(6, 12);
      _showMnemonicDialog = true;
    }
  }

  void showDialogGameOver() {
    showGameOverDialog(gameRef.context, () {
      // Restart the game
      Navigator.of(
        gameRef.context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => const Game()));
    });
  }

  @override
  void update(double dt) {
    if (_showMnemonicDialog && _pendingMnemonic != null) {
      _showMnemonicDialog = false;
      showMnemonicDialog(gameRef.context, _pendingMnemonic!, _isFirstHalf);
      _pendingMnemonic = null;
      _isFirstHalf = !_isFirstHalf;
    }

    if (checkInterval('gameOver', 100, dt)) {
      if (gameRef.player != null && gameRef.player?.isDead == true) {
        if (!showGameOver) {
          showGameOver = true;
          showDialogGameOver();
        }
      }
    }
    super.update(dt);
  }

  void showVerificationDialog() async {
    final String? accountMnemonic =
        await ServiceInjector().credentialsManager.restoreMnemonic();
    if (accountMnemonic == null) {
      _log.severe('Failed to get mnemonic from credentials manager');
      return;
    }

    final List<String> mnemonicWords = accountMnemonic.split(' ');
    // Select 3 random positions (1-based for user display)
    final positions = List.generate(12, (i) => i + 1)..shuffle(_random);
    final selectedPositions = positions.take(3).toList()..sort();
    final selectedWords =
        selectedPositions.map((pos) => mnemonicWords[pos - 1]).toList();
    showMnemonicVerificationDialog(
      gameRef.context,
      selectedPositions,
      selectedWords,
      () {
        // onSuccess: Stop audio and navigate to WalletHomScreen
        _audioService.stopBGM();
        Navigator.of(gameRef.context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const VictoryTransitionScreen(),
          ),
        );
      },
      () {
        // onRestart: Restart the Game
        Navigator.of(gameRef.context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Game()),
        );
      },
    );
  }
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _initializeFlameDevice();
    _audioService.playBGM();
  }

  @override
  void dispose() {
    _audioService.stopBGM();
    super.dispose();
  }

  Future<void> _initializeFlameDevice() async {
    // await Flame.device.fullScreen();
    await Flame.device.setPortrait();
  }

  @override
  Widget build(BuildContext context) {
    PlayerController joystick = Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load(
          'joystick/joystick_background.png',
        ),
        spriteKnobDirectional: Sprite.load('joystick/joystick_knob.png'),
        size: 100,
        margin: const EdgeInsets.only(bottom: 50, left: 50),
      ),
      actions: [
        JoystickAction(
          actionId: 0,
          sprite: Sprite.load('joystick/joystick_attack.png'),
          spritePressed: Sprite.load('joystick/joystick_attack_selected.png'),
          size: 80,
          margin: EdgeInsets.only(bottom: 50, right: 50),
        ),
      ],
    );

    final gameController = GameController(_audioService);

    return Material(
      color: Colors.transparent,
      child: BonfireWidget(
        playerControllers: [
          joystick,
          Keyboard(
            config: KeyboardConfig(
              acceptedKeys: [
                LogicalKeyboardKey.space,
                LogicalKeyboardKey.select,
              ],
            ),
          ),
        ],
        player: PlayerBob(Vector2(3 * tileSize, 1 * tileSize)),
        map: WorldMapByTiled(
          WorldMapReader.fromAsset('tiled/modern_map.json'),
          forceTileSize: Vector2(tileSize, tileSize),
          objectsBuilder: {
            'skeletel': (p) => SkeletonNpc(p.position),
            'muddy_enemy':
                (p) => MuddyEnemy(p.position, () {
                  gameController.showMnemonicAfterEnemyDefeat(true);
                }),
            'swampy_enemy':
                (p) => SwampyEnemy(p.position, () {
                  gameController.showMnemonicAfterEnemyDefeat(false);
                }),
            'key':
                (p) => DoorKey(p.position, () {
                  gameController.showVerificationDialog();
                }),
          },
        ),
        lightingColorGame: Colors.black.withValues(alpha: 0.2),
        backgroundColor: const Color(0xFF787173),
        interface: PlayerGameInterface(),
        cameraConfig: CameraConfig(
          speed: 3,
          zoom: getZoomFromMaxVisibleTile(context, tileSize, 18),
        ),
        components: [gameController],
      ),
    );
  }
}
