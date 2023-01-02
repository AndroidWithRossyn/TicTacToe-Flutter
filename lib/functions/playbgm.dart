import 'dart:async';

import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:audioplayers/audioplayers.dart';

class Music {
  static AudioCache cache = AudioCache(prefix: 'assets/music/');
  static AudioPlayer? player;
  static var _filename;
  static var _status;

  static get status => _status;

  static set status(status) {
    _status = status;
  }

  get filename => _filename;

  set filename(filename) {
    _filename = filename;
  }

  play(String file) async {
bool ply=await (utils.getSfxValue());
      
    if (ply) {
      _filename = file;
  
      if (_filename == backMusic) {

        player = await cache.loop(_filename);
         status = "playing";
      } else
        cache.play(_filename);
    }
  }

  static pause() async {
    if (await (utils.getSfxValue() as FutureOr<bool>)) {
      status = "paused";

      player!.pause();
    }
  }


  stop() async {
   
      status = "stopped";

     if(player!=null)
      player!.stop();
    
  }
}
