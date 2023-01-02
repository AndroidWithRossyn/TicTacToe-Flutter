import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/screens/multiplayer.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Multiplayer {
  final _userRef = FirebaseDatabase.instance.ref().child("users");

  static var _stream;

  static updateLocalList(
      String? gameKey, dynamic dbIns, void Function(dynamic b) update) {
    _stream = dbIns
        .ref()
        .child("Game")
        .child(gameKey)
        .child("buttons")
        .onChildChanged
        .listen((DatabaseEvent ev) {
      if (update != null) {
        update(ev);
      }
    });
  }

  static checkStatus(
    context,
    gameKey,
    dynamic buttons,
    winningCondition,
    gameStatus, {
    void Function(int index)? onWin,
    void Function(int index)? onTie,
  }) async {
    int called = 0;
    String? winner = "0";
    var tieCalled = 0;
    int _count = 0;

    for (var j = 0; j < winningCondition.length; j++) {
      if (buttons[winningCondition[j][0]]["player"] ==
              buttons[winningCondition[j][1]]["player"] &&
          buttons[winningCondition[j][1]]["player"] ==
              buttons[winningCondition[j][2]]["player"] &&
          buttons[winningCondition[j][1]]["player"] != "0") {
        winVar1 = winningCondition[j][0];
        winVar2 = winningCondition[j][1];
        winVar3 = winningCondition[j][2];

        winner = buttons[winningCondition[j][1]]["player"];

        if (called == 0 && winner != "0") {
          onWin!(j);

          called += 1;
        }
      }
    }
    for (int i = 0; i < buttons.length; i++) {
      if (buttons[i]["player"] != "0") {
        _count++;
      }
    }
    if (_count == 9 && winner == "0" && tieCalled == 0) {
      tieCalled++;
      music.play(tiegame);

      if (onTie != null) onTie(0);
    }
  }

  getPlayerNameByUid(uid) async {
    DatabaseEvent ref = await _userRef.child(uid).once();
    var result = (ref.snapshot.value as Map)["username"];
    return result;
  }

  updateMatchWonCount(String id) async {
    DatabaseEvent playerData = await _userRef.child(id).once();
    var matchWonCount = (playerData.snapshot.value as Map)["matchwon"];
    var newMatchwonCount = matchWonCount + 1;
    _userRef.child(id).update({"matchwon": newMatchwonCount});

    var matchPlayedCount = (playerData.snapshot.value as Map)["matchplayed"];
    var newMatchPlayedCount = matchPlayedCount + 1;
    _userRef.child(id).update({"matchplayed": newMatchPlayedCount});
  }

  updateMatchPlayedCount(BuildContext context,String id, [matchResult]) async {
    DatabaseEvent playerData = await _userRef.child(id).once();

    //update match count
    var matchPlayedCount = (playerData.snapshot.value as Map)["matchplayed"];
    var updatedMatchPlayedCount = matchPlayedCount + 1;
    _userRef.child(id).update({"matchplayed": updatedMatchPlayedCount});

    //update score
    if (matchResult != "" && matchResult != null) {
      var currentscore = (playerData.snapshot.value as Map)["score"];
      var updatedScore;

      if (matchResult == utils.getTranslated(context, "tie")) {
        updatedScore = currentscore + tieScore;
      } else if (matchResult == utils.getTranslated(context, "win")) {
        updatedScore = currentscore + winScore;
      } else {
        updatedScore = currentscore - loseScore;
      }

      _userRef.child(id).update({"score": updatedScore});
    }
  }

  static dispose() {
    _stream?.cancel();
  }
}
