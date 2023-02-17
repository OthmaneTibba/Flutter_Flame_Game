import 'dart:math';

import 'package:flame/components.dart';
import 'package:simple_game/components/knife.dart';
import 'package:simple_game/config/game_config.dart';
import 'package:simple_game/main.dart';

class KnifeSpawner extends Component with HasGameRef<MyGame> {
  Timer? timer;
  final Random _rand = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    timer = Timer(
      1,
      onTick: _spawnKnife,
      repeat: true,
    );
  }

  @override
  void update(double dt) {
    if (timer != null) {
      timer!.update(dt);
    }
    super.update(dt);
  }

  void _spawnKnife() {
    int randX = _rand.nextInt(GameConfig.screenWidth.toInt() - 80) + 1;
    gameRef.add(
      Knife(
        pos: Vector2(randX.toDouble(), 0),
      ),
    );
  }
}
