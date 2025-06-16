import 'package:bonfire/bonfire.dart';
import 'package:bitwit_shit/game/bar_life_component.dart';

class PlayerGameInterface extends GameInterface {
  @override
  Future<void> onLoad() async {
    add(MyBarLifeComponent());
    return super.onLoad();
  }
}
