// ignore_for_file: constant_identifier_names

import 'package:bitwit_shit/game/game.dart';
import 'package:flutter/material.dart';

const TILE_SIZE_SPRITE_SHEET = 16;

double valueByTileSize(double value) {
  return value * (tileSize / TILE_SIZE_SPRITE_SHEET);
}

EdgeInsets topRightJoystickMargin(
  BuildContext context, {
  required double right,
  double top = 10,
  double buttonSize = 50,
}) {
  final screenHeight = MediaQuery.of(context).size.height;
  final double bottomMargin = screenHeight - top - buttonSize;
  return EdgeInsets.only(bottom: bottomMargin, right: right);
}
