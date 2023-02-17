import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:simple_game/components/knife.dart';
import 'package:simple_game/components/player.dart';
import 'package:simple_game/components/wall.dart';
import 'package:simple_game/config/game_config.dart';
import 'package:simple_game/overlays/game_over.dart';
import 'package:simple_game/spawner/knife_spawner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  await FlameAudio.audioCache.load('SwingingPants.ogg');

  final myGame = MyGame();
  runApp(
    GameWidget(
      game: myGame,
      overlayBuilderMap: {
        GameOver.gameOverId: (context, game) => GameOver(
              game: myGame,
            ),
      },
    ),
  );
}

class MyGame extends FlameGame with HasTappables, HasCollisionDetection {
  late SpriteComponent background;
  late Player player;
  late Wall rightWall;
  late Wall leftWall;

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(
      Vector2(
        GameConfig.screenWidth,
        GameConfig.screenHeight,
      ),
    );
    background = SpriteComponent()
      ..sprite = await loadSprite('background/Background.png')
      ..size = Vector2(GameConfig.screenWidth, GameConfig.screenHeight)
      ..position = Vector2.zero();
    add(background);
    add(player = Player());
    add(
      rightWall = Wall(
        wallDir: WallDir.RIGHT,
        pos: Vector2(
          GameConfig.screenWidth - 5,
          0,
        ),
      ),
    );

    add(
      leftWall = Wall(
        wallDir: WallDir.LEFT,
        pos: Vector2(
          -5,
          0,
        ),
      ),
    );
    add(KnifeSpawner());
    children.register<Knife>();
    FlameAudio.bgm.play('SwingingPants.ogg');
    await super.onLoad();
  }

  void _handlePlayerMoving(TapDownInfo info) {
    if (info.eventPosition.viewport.x > GameConfig.screenWidth / 2) {
      player.moveRight();
    }
    if (info.eventPosition.viewport.x < GameConfig.screenWidth / 2) {
      player.moveLeft();
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    _handlePlayerMoving(info);
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    super.onTapUp(pointerId, info);
    player.stopMoving();
  }

  @override
  void onLongTapDown(int pointerId, TapDownInfo info) {
    super.onLongTapDown(pointerId, info);
    _handlePlayerMoving(info);
  }

  void resetGame() {
    children.query<Knife>().forEach((element) {
      element.removeFromParent();
    });
    FlameAudio.bgm.play('SwingingPants.ogg');
    overlays.remove(GameOver.gameOverId);
    resumeEngine();
  }
}
