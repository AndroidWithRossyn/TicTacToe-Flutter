import 'dart:async';
import 'dart:math' as f;

import 'package:TicTacToe/models/createGameModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FindGame {

  FirebaseDatabase _ins = FirebaseDatabase.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;


  createGames(entryFee, round) {
    var game = _ins.ref().child("Game").push();
    var key = game.key;
    var random = f.Random();
    var randomInt = random.nextInt(2);
    var player = randomInt == 0 ? "player1" : "player2";

    var create = CreateGame(
        player1: _auth.currentUser!.uid.toString(),
        entryfee: entryFee,
        round: round,
        tryy: player);
    game.set(create.toMap());

    return key;
  }

  Future<Map<String, dynamic>> joinGame(entryFee, round) async {
    JoinStatus joinGameStatus = JoinStatus.pending;
    String roomKey = "";
    String? oppornentKey = "";

    DatabaseEvent dta;

    dta = await _ins.ref().child("Game").once();

    //--if there are no Game
    if (dta.snapshot.value == null) {
      roomKey = await createGames(entryFee, round);
      joinGameStatus = JoinStatus.created;
    }


    bool gameAvailable = false;
    if (dta.snapshot.value != null) {
      Map<dynamic, dynamic> valMap = dta.snapshot.value as Map;

      for (int i = 0; i < valMap.length; i++) {
        var tim = valMap.values.elementAt(i)["time"];

        var dif = timeDifferance(tim);
        var status = valMap.values.elementAt(i)["status"];
        var player1 = valMap.values.elementAt(i)["player1"]["id"];
        var _entryFee = valMap.values.elementAt(i)["entryFee"];
        var _round = valMap.values.elementAt(i)["round"];

        if (dif == 0 &&
            player1 != FirebaseAuth.instance.currentUser!.uid &&
            status == "pending" &&
            _entryFee == entryFee &&
            _round == round) {
          gameAvailable = true;
          roomKey = valMap.keys.elementAt(i);
          oppornentKey = player1;
          break;
        }
      }

      if (!gameAvailable && joinGameStatus != JoinStatus.created) {
        roomKey = createGames(entryFee, round);
        joinGameStatus = JoinStatus.created;
      } else {

        _ins.ref().child("Game").child(roomKey).update({
          "status": "prepering",

        });

        _ins
            .ref()
            .child("Game")
            .child(roomKey)
            .child("player2")
            .update({"id": _auth.currentUser!.uid, "won": 0});

        joinGameStatus = JoinStatus.joined;
      }


    }

    Map<String, dynamic> map = Map.from({
      "JoinStatus": joinGameStatus,
      "roomKey": roomKey,
      "oppornentKey": oppornentKey
    });

    return map;
  }

  int timeDifferance(time) {
    DateTime gameCreatedDate = DateTime.parse(time);
    DateTime nowDate = DateTime.now();


    int differance = gameCreatedDate.difference(nowDate).inMinutes;
     return differance;
  }
}

enum JoinStatus {
  created,
  joined,
  pending,
  error,
}

