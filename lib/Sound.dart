import 'package:flutter/cupertino.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class Sound {
  Soundpool soundPool;

  void init() {
    instantiate();
  }

  Future<void> instantiate() async {
    WidgetsFlutterBinding.ensureInitialized();
    soundPool = Soundpool();
  }

  Future<int> loadSound() async {
    var asset = await rootBundle.load("assets/sounds/widefngr.wav");
    return await soundPool.load(asset);
  }

  Future<void> playSound(Future<int> soundId) async {
    var _sound = await soundId;
    await soundPool.play(_sound);
  }
}
