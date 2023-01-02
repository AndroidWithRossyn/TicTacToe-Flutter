import 'package:flutter/services.dart';

class SoundEffect {
  final ByteData? click;
  final ByteData? wingame;
  final ByteData? tiegame;
  final ByteData? losegame;
  final ByteData? dice;
  final ByteData? buy;

  SoundEffect({
    this.click,
    this.wingame,
    this.tiegame,
    this.losegame,
    this.dice,
    this.buy,
  });
}
