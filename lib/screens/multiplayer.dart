import 'dart:async';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/functions/dialoges.dart';
import 'package:TicTacToe/functions/gameHistory.dart';
import 'package:TicTacToe/functions/getCoin.dart';
import 'package:TicTacToe/functions/multiplayer.dart';
import 'package:TicTacToe/widgets/alertDialoge.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'splash.dart';

class MultiplayerScreen extends StatelessWidget {
  final firstTry;
  final gameKey;
  final oppornentName;
  final oppornentPic;
  final int? round;
  final imagex;
  final imageo;

  const MultiplayerScreen({
    Key? key,
    this.gameKey,
    this.firstTry,
    this.oppornentName,
    this.oppornentPic,
    this.round,
    this.imagex,
    this.imageo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: MultiplayerScreenActivity(
        firstTry: firstTry,
        gameKey: gameKey,
        oppornentName: oppornentName,
        oppornentPic: oppornentPic,
        round: round,
        imagex: imagex,
        imageo: imageo,
      )),
    );
  }
}

int? winVar1, winVar2, winVar3;
bool? winGame;

class MultiplayerScreenActivity extends StatefulWidget {
  final firstTry;
  final gameKey;
  final oppornentName;
  final oppornentPic;
  final round;
  final imagex;
  final imageo;

  const MultiplayerScreenActivity(
      {Key? key,
      this.gameKey,
      this.firstTry,
      this.oppornentName,
      this.oppornentPic,
      this.round,
      this.imagex,
      this.imageo})
      : super(key: key);

  @override
  _MultiplayerScreenActivityState createState() =>
      _MultiplayerScreenActivityState();
}

class _MultiplayerScreenActivityState extends State<MultiplayerScreenActivity> {
  //-----//
  FirebaseDatabase _ins = FirebaseDatabase.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  CountDownController _countDownPlayer = CountDownController();

  StateSetter? dialogState;

  String? playerValue;
  String gameStatus = "";
  bool? yourTry;
  String? username, profilePic;
  String? uid;
  Map buttons = Map();
  List timerButtons = [];
  String? player1Id, player2Id;
  late DatabaseReference _gameRef;
  late DatabaseReference _userRef;
  int playcountdown = 3;
  Duration animationDuration = Duration(seconds: 3);
  double itemSize = 0;
  double opacity = 1;
  Timer? playclocktimer;

  late String timerUpof;
  var gameIns;
  var diceSound;
  var diceIns;
  bool istimerCompleted = false;
  String whoseTimeout = "";

  StreamSubscription? subs;
  Multiplayer multi = Multiplayer();
  int curRound = 1;
  bool closedByUs = false;
  Future<DatabaseEvent>? _gameSnapshot;
  int win1Count = 0, win2Count = 0, tieCount = 0;

  @override
  void initState() {
    super.initState();

    winVar1 = null;
    winVar2 = null;
    winVar3 = null;
    winGame = null;

    yourTry = widget.firstTry;
    //db referance
    _gameRef = _ins.ref().child("Game");
    _userRef = _ins.ref().child("users");

    _gameSnapshot = _gameRef.child(widget.gameKey).once();

    buttons = new Map<int, dynamic>.from(utils.gameButtons);
    buttons = copyDeepMap(utils.gameButtons);

    getGamebuttons();

    _ins
        .ref()
        .child("Game")
        .child(widget.gameKey)
        .update({"status": "running"});

    getFieldValue("profilePic", (e) => profilePic = e, (e) => profilePic = e);
    getFieldValue("username", (e) => username = e, (e) => username = e);

    //----Listen Updates in database and Update local buttons list when data changes
    Multiplayer.updateLocalList(widget.gameKey, _ins, (ev) async {
      music.play(dice);
      buttons[int.parse(ev.snapshot.key.trim())] = await ev.snapshot.value;

      status();
      setState(() {});
    });
//start timer according to turn
    getuserDetails();
    gameStatusListener();
  }

  getFieldValue(
    String fieldName,
    void Function(dynamic count) callback,
    void Function(dynamic count) update,
  ) async {
    var init;
    try {
      var ins = GetUserInfo();
      init = await (await ins.getFieldValue(fieldName));
      if (mounted) {
        setState(() {
          callback(init);
        });
      }

      await ins.detectChange(fieldName, (val) {
        if (mounted) {
          setState(() {
            update(val);
          });
        }
      });
    } catch (err) {}
  }

  Future<void> getuserDetails() async {
    await getPlayerValue();
  }

  Map copyDeepMap(Map map) {
    Map newMap = {};

    map.forEach((key, value) {
      newMap[key] = (value is Map) ? copyDeepMap(value) : value;
    });

    return newMap;
  }

  //check game status
  void status() {
    Multiplayer.checkStatus(
        context, widget.gameKey, buttons, utils.winningCondition, gameStatus,
        onWin: (int currentIndex) async {
      // fetch winner players name
      uid = await getUidByPlayer(
          buttons[utils.winningCondition[currentIndex][1]]["player"]);

      //get winner players total win count
      DatabaseEvent winCount = await _ins
          .ref()
          .child("Game")
          .child(widget.gameKey)
          .child(buttons[utils.winningCondition[currentIndex][1]]["player"])
          .child("won")
          .once();

      // increse winner's winCount by one in DB
      var kUid = _auth.currentUser!.uid;
      if (uid == kUid) {
        await _ins
            .ref()
            .child("Game")
            .child(widget.gameKey)
            .child(playerValue!)
            .update({"won": int.parse(winCount.snapshot.value.toString()) + 1});
      }
    }, onTie: (i) {
      tieCount += 1;
      _ins.ref().child("Game").child(widget.gameKey).update({"tie": tieCount});
    });
  }

  Future<void> getPlayerValue() async {
    DatabaseEvent find = await _gameRef.child(widget.gameKey).once();
    String tryy = (find.snapshot.value as Map)["try"];

    DatabaseEvent uid = await _gameRef.child(widget.gameKey).child(tryy).once();

    if ((uid.snapshot.value as Map)["id"] == _auth.currentUser!.uid) {
      yourTry = true;
    } else {
      yourTry = false;
    }
    DatabaseEvent player1snap = await _gameRef
        .child(widget.gameKey)
        .child("player1")
        .child("id")
        .once();
    DatabaseEvent player2snap = await _gameRef
        .child(widget.gameKey)
        .child("player2")
        .child("id")
        .once();

    player1Id = player1snap.snapshot.value.toString();
    player2Id = player2snap.snapshot.value.toString();

    _countDownPlayer.start();
    playerValue = tryy;
  }

  Future<void> updateCoin(String winnerId) async {
    //var uniqueId = _auth.currentUser.uid;
    DatabaseEvent entryfeeSnapshot =
        await _gameRef.child(widget.gameKey).once();
    int entryfee = (entryfeeSnapshot.snapshot.value as Map)["entryFee"];
    DatabaseEvent oldCoin = await _userRef.child(winnerId).once();
    int coins = (oldCoin.snapshot.value as Map)["coin"];
    int sum = coins + (entryfee * 2);
    _userRef.child(winnerId).update({"coin": sum});
  }

  Future<void> updateTieCoin() async {
    //var uniqueId = _auth.currentUser.uid;
    DatabaseEvent entryfeeSnapshot =
        await _gameRef.child(widget.gameKey).once();
    int entryfee = (entryfeeSnapshot.snapshot.value as Map)["entryFee"];
    DatabaseEvent oldCoin = await _userRef.child(_auth.currentUser!.uid).once();
    int coins = (oldCoin.snapshot.value as Map)["coin"];
    int sum = coins + entryfee;
    _userRef.child(_auth.currentUser!.uid).update({"coin": sum});
  }

  //change listener
  gameStatusListener() {
    subs = _ins
        .ref()
        .child("Game")
        .child(widget.gameKey)
        .onChildChanged
        .listen((event) async {
      if (event.snapshot.key == 'try') {
        DatabaseEvent uid2 = await _gameRef
            .child(widget.gameKey)
            .child(event.snapshot.value.toString())
            .child("id")
            .once();

        if (uid2.snapshot.value == _auth.currentUser!.uid) {
          yourTry = true;
        } else {
          yourTry = false;
        }
        _countDownPlayer.restart();
        playerValue = event.snapshot.value == "player1" ? "player1" : "player2";
        if (mounted) setState(() {});
      }
      if (event.snapshot.key == "status") {
        /** -------- */
        DatabaseEvent entryfeeSnapshot =
            await _gameRef.child(widget.gameKey).once();

        DatabaseEvent player1Snapshot =
            await _gameRef.child(widget.gameKey).child("player1").once();
        DatabaseEvent player2Snapshot =
            await _gameRef.child(widget.gameKey).child("player2").once();
        int? entryfee = (entryfeeSnapshot.snapshot.value as Map)["entryFee"];
        String? player1 = (player1Snapshot.snapshot.value as Map)["id"];
        String? player2 = (player2Snapshot.snapshot.value as Map)["id"];

        //    String id = player1 == _auth.currentUser.uid ? player1 : player2;
        /** -------- */

        if (event.snapshot.value == "closed" && mounted) {
          Dialoge d = Dialoge();
          /** ----counter---- */

          _countDownPlayer.pause();
          /** -------- */

          await Future.delayed(Duration(seconds: 1));

          if (mounted && closedByUs == false) {
            await updateCoin(_auth.currentUser!.uid);
            multi.updateMatchWonCount(_auth.currentUser!.uid);
            multi.updateMatchPlayedCount(context, _auth.currentUser!.uid,
                utils.getTranslated(context, "win"));
            History().update(
                uid: FirebaseAuth.instance.currentUser!.uid,
                date: DateTime.now().toString(),
                gameid: widget.gameKey,
                gotcoin: entryfee! * 2,
                oppornentId:
                    player1 == _auth.currentUser!.uid ? player2 : player1,
                status: "Opponent disconnect",
                type: "OD");
            d.oppornentDisconnect(context, entryfee, widget.gameKey);
          }
          if (widget.gameKey != null) {
            Dialoge.removeChild("Game", widget.gameKey);
          }
        }
      }

      if (event.snapshot.key == "player2" || event.snapshot.key == "player1") {
        DatabaseEvent snap = await _gameRef
            .child(widget.gameKey)
            .child(event.snapshot.key!)
            .child("id")
            .once();
        if (mounted) {
          /** ----win & loose sound---- */

          snap.snapshot.value == _auth.currentUser!.uid
              ? music.play(wingame)
              : music.play(losegame);
        }
        /** ----stop counter---- */

        _countDownPlayer.pause();

        DatabaseEvent p1Count = await _gameRef
            .child(widget.gameKey)
            .child("player1")
            .child("won")
            .once();

        win1Count = int.parse(p1Count.snapshot.value.toString());

        DatabaseEvent p2Count = await _gameRef
            .child(widget.gameKey)
            .child("player2")
            .child("won")
            .once();

        win2Count = int.parse(p2Count.snapshot.value.toString());

        snap.snapshot.value == _auth.currentUser!.uid
            ? winGame = true
            : winGame = false;

        Timer(Duration(seconds: 3), () async {
          winVar1 = null;
          winVar2 = null;
          winVar3 = null;
          winGame = null;

          DatabaseEvent r = await FirebaseDatabase.instance
              .ref()
              .child("Game")
              .child(widget.gameKey)
              .child("entryFee")
              .once();

          if (curRound != widget.round) {
            // set button values to default in DB
            for (int i = 0; i < buttons.length; i++) {
              _gameRef
                  .child(widget.gameKey)
                  .child("buttons")
                  .child("$i")
                  .update({"player": "0", "state": ""});
            }
          }

          //last round
          if (widget.round == curRound) {
            /** ----dialoge---- */
            _gameRef.child(widget.gameKey).update({"status": "closed"});
            closedByUs = true;
            setState(() {});

            //let's check which player is winner
            var winnerId, looserId;
            String winText, point;

            DatabaseEvent playersData =
                await _gameRef.child(widget.gameKey).once();

            if (win1Count > win2Count) {
              winnerId = (playersData.snapshot.value as Map)["player1"]["id"];
              looserId = (playersData.snapshot.value as Map)["player2"]["id"];
            } else {
              winnerId = (playersData.snapshot.value as Map)["player2"]["id"];
              looserId = (playersData.snapshot.value as Map)["player1"]["id"];
            }

            if (win1Count == win2Count) {
              winnerId = "";
            }
            if (winnerId != "") {
              winText = winnerId == _auth.currentUser!.uid
                  ? utils.getTranslated(context, "priceWin"): utils.getTranslated(context, "youLose");
              point = winnerId == _auth.currentUser!.uid
                  ? (int.parse(r.snapshot.value.toString()) * 2).toString()
                  : r.snapshot.value.toString();

              Dialoge.winner(
                  context,
                  winnerId == _auth.currentUser!.uid
                      ? username
                      : "${utils.limitChar(widget.oppornentName, 15)}",
                  winnerId == _auth.currentUser!.uid
                      ? profilePic
                      : "${widget.oppornentPic}",
                  winText,
                  point,
                  widget.gameKey);

              var _tempData = (await _gameSnapshot)!.snapshot.value;

              if (winnerId == _auth.currentUser!.uid) {
                History().update(
                    uid: winnerId,
                    date: DateTime.now().toString(),
                    gameid: widget.gameKey,
                    gotcoin: (_tempData as Map)["entryFee"] * 2,
                    oppornentId: looserId,
                    status: "Won",
                    type: "GAME");
                //looser's history update
                History().update(
                    uid: looserId,
                    date: DateTime.now().toString(),
                    gameid: widget.gameKey,
                    gotcoin: -_tempData["entryFee"],
                    oppornentId: winnerId,
                    status: "Lose",
                    type: "GAME");

                multi.updateMatchWonCount(winnerId);
                multi.updateMatchPlayedCount(
                    context, winnerId, utils.getTranslated(context, "win"));
                multi.updateMatchPlayedCount(
                    context, looserId, utils.getTranslated(context, "lose"));
                await updateCoin(winnerId);
              }
            } else {
              updateTieCoin();
              Dialoge dialog = Dialoge();
              dialog.tieMultiplayer(context, widget.gameKey);
            }

            if (widget.gameKey != null) {
              Dialoge.removeChild("Game", widget.gameKey);
            }
          } else {
            var winnerId = snap.snapshot.value;
            var winText = winnerId == _auth.currentUser!.uid
                ? utils.getTranslated(context, "priceWin"): utils.getTranslated(context, "youLose");
            var point = winnerId == _auth.currentUser!.uid
                ? (int.parse(r.snapshot.value.toString()) * 2).toString()
                : r.snapshot.value.toString();

            if (win1Count > (widget.round / 2) ||
                win2Count > (widget.round / 2)) {
              _gameRef.child(widget.gameKey).update({"status": "closed"});

              closedByUs = true;
              setState(() {});

              var looserId;
              DatabaseEvent data;

              if (win1Count > win2Count) {
                data = await _gameRef
                    .child(widget.gameKey)
                    .child("player2")
                    .child("id")
                    .once();
                looserId = data.snapshot.value;
              } else {
                data = await _gameRef
                    .child(widget.gameKey)
                    .child("player1")
                    .child("id")
                    .once();
                looserId = data.snapshot.value;
              }
              Dialoge.winner(
                  context,
                  winnerId == _auth.currentUser!.uid
                      ? username
                      : "${utils.limitChar(widget.oppornentName, 15)}",
                  winnerId == _auth.currentUser!.uid
                      ? profilePic
                      : "${widget.oppornentPic}",
                  winText,
                  point,
                  widget.gameKey);

              var _tempData = (await _gameSnapshot)!.snapshot.value;
              if (winnerId == _auth.currentUser!.uid) {
                History().update(
                    uid: winnerId,
                    date: DateTime.now().toString(),
                    gameid: widget.gameKey,
                    gotcoin: (_tempData as Map)["entryFee"] * 2,
                    oppornentId: looserId,
                    status: "Won",
                    type: "GAME");
                //looser's history update
                History().update(
                    uid: looserId,
                    date: DateTime.now().toString(),
                    gameid: widget.gameKey,
                    gotcoin: -_tempData["entryFee"],
                    oppornentId: winnerId,
                    status: "Lose",
                    type: "GAME");

                multi.updateMatchWonCount(winnerId.toString());
                multi.updateMatchPlayedCount(context, winnerId.toString(),
                    utils.getTranslated(context, "win"));
                multi.updateMatchPlayedCount(
                    context, looserId, utils.getTranslated(context, "lose"));
                await updateCoin(winnerId.toString());
              }

              if (widget.gameKey != null) {
                Dialoge.removeChild("Game", widget.gameKey);
              }
            } else {
              _countDownPlayer.pause();

              // Dialoge d = new Dialoge();
              nextRoundDialog(
                winnerId == _auth.currentUser!.uid
                    ? "$username won"
                    : "${utils.limitChar(widget.oppornentName, 15)} won",
              );
            }
          }
        });
      }
      if (event.snapshot.key == "tie") {
        if (widget.round == curRound) {
          // Let's try to decide the winner...
          DatabaseEvent idAndWinCountofPlayer1 = await _ins
              .ref()
              .child("Game")
              .child(widget.gameKey)
              .child("player1")
              .once();

          DatabaseEvent idAndWinCountofPlayer2 = await _ins
              .ref()
              .child("Game")
              .child(widget.gameKey)
              .child("player2")
              .once();

          DatabaseEvent entryFee = await FirebaseDatabase.instance
              .ref()
              .child("Game")
              .child(widget.gameKey)
              .child("entryFee")
              .once();

          var winCountOfPlayer1 =
              (idAndWinCountofPlayer1.snapshot.value as Map)['won'];
          var winCountOfPlayer2 =
              (idAndWinCountofPlayer2.snapshot.value as Map)['won'];
          var idOfPlayer1 =
              (idAndWinCountofPlayer1.snapshot.value as Map)['id'];
          var idOfPlayer2 =
              (idAndWinCountofPlayer2.snapshot.value as Map)['id'];

          var winnerId;
          String winText, earnedCoin;

          if (winCountOfPlayer1 == winCountOfPlayer2) {
            winnerId = "";
          }
          winText = winnerId == _auth.currentUser!.uid
              ? utils.getTranslated(context, "priceWin"): utils.getTranslated(context, "youLose");
          earnedCoin = winnerId == _auth.currentUser!.uid
              ? (int.parse(entryFee.snapshot.value.toString()) * 2).toString()
              : entryFee.snapshot.value.toString();

          _gameRef.child(widget.gameKey).update({"status": "closed"});
          closedByUs = true;
          _countDownPlayer.pause();
          setState(() {});
          if (winnerId == "") {
            Dialoge d = Dialoge();
            d.tieMultiplayer(context, widget.gameKey);
            updateTieCoin();

            var _tempData = (await _gameSnapshot)!.snapshot.value;
            if (idOfPlayer1 == _auth.currentUser!.uid) {
              History().update(
                  uid: idOfPlayer2,
                  date: DateTime.now().toString(),
                  gameid: widget.gameKey,
                  gotcoin: (_tempData as Map)["entryFee"],
                  oppornentId: idOfPlayer1,
                  status: "Tie",
                  type: "TIE GAME");
              //looser's history update
              History().update(
                  uid: idOfPlayer1,
                  date: DateTime.now().toString(),
                  gameid: widget.gameKey,
                  gotcoin: _tempData["entryFee"],
                  oppornentId: idOfPlayer2,
                  status: "Tie",
                  type: "TIE GAME");

              multi.updateMatchPlayedCount(
                  context, idOfPlayer1, utils.getTranslated(context, "tie"));
              multi.updateMatchPlayedCount(
                  context, idOfPlayer2, utils.getTranslated(context, "tie"));
            }
          } else {
            var looserId;
            if (winCountOfPlayer1 > winCountOfPlayer2) {
              winnerId = idOfPlayer1;
              looserId = idOfPlayer2;
            } else {
              winnerId = idOfPlayer2;
              looserId = idOfPlayer1;
            }

            Dialoge.winner(
                context,
                winnerId == _auth.currentUser!.uid
                    ? username
                    : "${utils.limitChar(widget.oppornentName, 15)}",
                winnerId == _auth.currentUser!.uid
                    ? profilePic
                    : "${widget.oppornentPic}",
                winText,
                earnedCoin,
                widget.gameKey);

            var _tempData = (await _gameSnapshot)!.snapshot.value;

            if (winnerId == _auth.currentUser!.uid) {
              History().update(
                  uid: winnerId,
                  date: DateTime.now().toString(),
                  gameid: widget.gameKey,
                  gotcoin: (_tempData as Map)["entryFee"] * 2,
                  oppornentId: looserId,
                  status: "Won",
                  type: "GAME");
              //looser's history update
              History().update(
                  uid: looserId,
                  date: DateTime.now().toString(),
                  gameid: widget.gameKey,
                  gotcoin: -_tempData["entryFee"],
                  oppornentId: winnerId,
                  status: "Lose",
                  type: "GAME");

              multi.updateMatchWonCount(winnerId);
              multi.updateMatchPlayedCount(
                  context, winnerId, utils.getTranslated(context, "win"));
              multi.updateMatchPlayedCount(
                  context, looserId, utils.getTranslated(context, "lose"));
              await updateCoin(winnerId);
            }
          }

          if (widget.gameKey != null) {
            Dialoge.removeChild("Game", widget.gameKey);
          }
        }
        if (widget.round != curRound && curRound < widget.round) {
          _countDownPlayer.pause();

          for (int i = 0; i < buttons.length; i++) {
            _gameRef
                .child(widget.gameKey)
                .child("buttons")
                .child("$i")
                .update({"player": "0", "state": ""});
          }
          nextRoundDialog(
            utils.getTranslated(context, "tie"),
          );
        }

        _countDownPlayer.pause();
      }
    });
  }

  nextRoundDialog(String subtitle) {
    itemSize = 90;
    // opacity = 0;

    playclocktimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (mounted && dialogState != null) {
        dialogState!(() {
          playcountdown--;
        });
      }

      if (playcountdown <= 0) {
        if (playclocktimer != null) playclocktimer!.cancel();

        _countDownPlayer.restart();
        curRound = curRound + 1;
        buttons = copyDeepMap(utils.gameButtons);
        playcountdown = 3;
        setState(() {
          winVar1 = null;
          winVar2 = null;
          winVar3 = null;
          winGame = null;
        });

        Navigator.pop(context);
      }
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              dialogState = setState;
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    title: Text(utils.getTranslated(context, "nextRound"),
                        style: TextStyle(color: white),
                        textAlign: TextAlign.center),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(subtitle,
                            style: TextStyle(color: white),
                            textAlign: TextAlign.center),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedOpacity(
                            duration: animationDuration,
                            opacity: opacity,
                            child: AnimatedContainer(
                              duration: animationDuration,
                              width: itemSize,
                              height: itemSize,
                              decoration: new BoxDecoration(
                                color: white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Text(
                                playcountdown.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        )
                      ],
                    )),
              );
            }));
  }

  Future<String?> getUidByPlayer(String target) async {
    DatabaseEvent ref =
        await _gameRef.child(widget.gameKey).child(target).child("id").once();
    String? result = ref.snapshot.value.toString();
    return result;
  }

  //it returns Image for X and O
  returnImage(i) {
    if (istimerCompleted) {
      if (buttons[i]["player"] == whoseTimeout) {
        return "assets/images/dora_timeout.png";
      } else {
        return widget.imageo;
      }
    } else if (winVar1 != null &&
        winVar2 != null &&
        winVar3 != null &&
        winGame != null &&
        winGame! &&
        (i == winVar1 || i == winVar2 || i == winVar3))
      return "assets/images/dora_win.png";
    else if (winVar1 != null &&
        winVar2 != null &&
        winVar3 != null &&
        winGame != null &&
        !winGame! &&
        (i == winVar1 || i == winVar2 || i == winVar3))
      return "assets/images/dora_lose.png";
    else if (buttons[i]["player"] == "player1" && buttons[i]["player"] != "0") {
      if (player1Id == _auth.currentUser!.uid) {
        return widget.imagex;
      }
      return widget.imageo;
    } else if (buttons[i]["player"] == "player2" &&
        buttons[i]["player"] != "0") {
      if (player2Id == _auth.currentUser!.uid) {
        return widget.imagex;
      }
      return widget.imageo;
    }
  }

  void playGame(int i) async {
    if (buttons[i]["state"] == "") {
      //update value in local list
      buttons[i]["state"] = "true";
      buttons[i]["player"] = "$playerValue";

      //--update data
      await _gameRef
          .child(widget.gameKey)
          .child("buttons")
          .child("$i")
          .update({"player": playerValue, "state": "true"});
      //update try
      await _gameRef.child(widget.gameKey).update({
        "try": playerValue == "player1" ? "player2" : "player1",
      });

      //player = "X";
      setState(() {});
    }
  }

  @override
  void dispose() {
    subs?.cancel();

    Multiplayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) {
              var color = secondaryColor;

              return Alert(
                title: Text(
                  utils.getTranslated(context, "aleart"),
                  style: TextStyle(color: white),
                ),
                isMultipleAction: true,
                defaultActionButtonName: utils.getTranslated(context, "yes"),
                onTapActionButton: () {},
                content: Text(
                  utils.getTranslated(context, "areYouSure"),
                  style: TextStyle(color: white),
                ),
                multipleAction: [
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(color)),
                      onPressed: () async {
                        music.play(click);
                        DatabaseEvent snap =
                            await _gameRef.child(widget.gameKey).once();

                        if (snap.snapshot.value != null) {
                          _gameRef
                              .child(widget.gameKey)
                              .update({"status": "closed"}).then((value) {
                            closedByUs = true;
                            setState(() {});
                          });

                          var player1snap = await _gameRef
                              .child(widget.gameKey)
                              .child("player1")
                              .child("id")
                              .once();
                          var player2snap = await _gameRef
                              .child(widget.gameKey)
                              .child("player2")
                              .child("id")
                              .once();
                          History().update(
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              date: DateTime.now().toString(),
                              gameid: widget.gameKey,
                              gotcoin:
                                  -(snap.snapshot.value as Map)["entryFee"],
                              oppornentId: player1snap.snapshot.value ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? player2snap.snapshot.value
                                  : player1snap.snapshot.value,
                              status: "Closed Game",
                              type: "CLOSEDGAME");

                          music.play(click);

                          multi.updateMatchPlayedCount(
                              context,
                              _auth.currentUser!.uid,
                              utils.getTranslated(context, "lose"));
                        }
                        Navigator.popUntil(
                            context, ModalRoute.withName("/home"));
                      },
                      child: Text(utils.getTranslated(context, "yes"),
                          style: TextStyle(color: white))),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(color)),
                      onPressed: () async {
                        music.play(click);

                        Navigator.pop(context);
                      },
                      child: Text(utils.getTranslated(context, "no"),
                          style: TextStyle(color: white)))
                ],
              );
            });

        if (widget.gameKey != null) {
          Dialoge.removeChild("Game", widget.gameKey);
        }
        return Future<bool>.value(true);
      },
      child: Container(
        decoration: utils.gradBack(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // yourTry == false
                  Row(
                    children: [
                      CircularCountDownTimer(
                        height: 25,
                        duration: countdowntime,
                        ringColor: back,
                        fillColor: secondarySelectedColor,
                        strokeWidth: 3,
                        width: 25,
                        controller: _countDownPlayer,
                        textFormat: CountdownTextFormat.S,
                        textStyle: TextStyle(color: white, fontSize: 10),
                        // autoStart: yourTry == false ? true : false,
                        isReverse: true,
                        onComplete: () async {
                          DatabaseEvent status = await _ins
                              .ref()
                              .child("Game")
                              .child(widget.gameKey)
                              .child("status")
                              .once();

                          if (status.snapshot.value == "running") {
                            DatabaseEvent whosTimeout = await _ins
                                .ref()
                                .child("Game")
                                .child(widget.gameKey)
                                .child("try")
                                .once();

                            whoseTimeout =
                                whosTimeout.snapshot.value.toString();

                            Future.delayed(Duration(seconds: 3))
                                .then((value) async {
                              istimerCompleted = false;
                              String? playersUserId = await getUidByPlayer(
                                  whosTimeout.snapshot.value.toString());
                              String winnerPlayer =
                                  whosTimeout.snapshot.value == "player1"
                                      ? "player2"
                                      : "player1";

                              if (_auth.currentUser!.uid == playersUserId) {
                                DatabaseEvent winCount = await _ins
                                    .ref()
                                    .child("Game")
                                    .child(widget.gameKey)
                                    .child(winnerPlayer)
                                    .child("won")
                                    .once();

                                await _ins
                                    .ref()
                                    .child("Game")
                                    .child(widget.gameKey)
                                    .child(winnerPlayer)
                                    .update({
                                  "won": int.parse(
                                          winCount.snapshot.value.toString()) +
                                      1
                                });
                              }
                            });
                          }
                          setState(() {
                            istimerCompleted = true;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: Text(yourTry!
                            ? utils.getTranslated(context, "yourMove"): utils.getTranslated(context, "opponentMove")),
                      )
                    ],
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              var color = secondaryColor;
                              return Alert(
                                title: Text(
                                  utils.getTranslated(context, "aleart"),
                                  style: TextStyle(color: white),
                                ),
                                isMultipleAction: true,
                                defaultActionButtonName:
                                    utils.getTranslated(context, "yes"),
                                onTapActionButton: () {},
                                content: Text(
                                  utils.getTranslated(context, "areYouSure"),
                                  style: TextStyle(color: white),
                                ),
                                multipleAction: [
                                  TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(color)),
                                      onPressed: () async {
                                        music.play(click);

                                        _gameRef.child(widget.gameKey).update(
                                            {"status": "closed"}).then((value) {
                                          closedByUs = true;
                                          setState(() {});
                                        });
                                        var snap = await _gameRef
                                            .child(widget.gameKey)
                                            .once();
                                        var player1snap = await _gameRef
                                            .child(widget.gameKey)
                                            .child("player1")
                                            .child("id")
                                            .once();
                                        var player2snap = await _gameRef
                                            .child(widget.gameKey)
                                            .child("player2")
                                            .child("id")
                                            .once();
                                        History().update(
                                            uid: FirebaseAuth
                                                .instance.currentUser!.uid,
                                            date: DateTime.now().toString(),
                                            gameid: widget.gameKey,
                                            gotcoin: -(snap.snapshot.value
                                                as Map)["entryFee"],
                                            oppornentId: player1snap
                                                        .snapshot.value ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                ? player2snap.snapshot.value
                                                : player1snap.snapshot.value,
                                            status: "Closed Game",
                                            type: "CLOSEDGAME");

                                        music.play(click);

                                        multi.updateMatchPlayedCount(
                                            context,
                                            _auth.currentUser!.uid,
                                            utils.getTranslated(
                                                context, "lose"));

                                        Navigator.popUntil(context,
                                            ModalRoute.withName("/home"));
                                      },
                                      child: Text(
                                          utils.getTranslated(context, "yes"),
                                          style: TextStyle(color: white))),
                                  TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(color)),
                                      onPressed: () async {
                                        music.play(click);

                                        if (widget.gameKey != null) {
                                          Dialoge.removeChild(
                                              "Game", widget.gameKey);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                          utils.getTranslated(context, "no"),
                                          style: TextStyle(color: white)))
                                ],
                              );
                            });
                      },
                      icon: Icon(
                        Icons.logout,
                        color: white,
                      ))
                ],
              ),
            ),
            Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28.0),
              child: Text(
                "${utils.getTranslated(context, "roundLbl")} $curRound",
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(color: white, fontWeight: FontWeight.bold),
              ),
            )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Center(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0),
                    itemCount: 9,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () async {

                          if ((buttons[i]['state'] == '' ||
                                  buttons[i]['state'] == null) &&
                              (winVar1 == null &&
                                  winVar2 == null &&
                                  winVar3 == null &&
                                  winGame == null)) {
                            if (yourTry == true) {
                              playGame(i);
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/grid_box.png"),
                                  fit: BoxFit.fill)),
                          child: buttons[i] == null || buttons[i]['state'] == ""
                              ? Container()
                              : Image.asset(returnImage(i)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: secondaryColor,
                          backgroundImage: profilePic == null
                              ? null
                              : NetworkImage(profilePic!),
                          radius: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${utils.getTranslated(context, "sign")} :",
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(color: white),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                  Image.asset(
                                    widget.imagex,
                                    height: 12,
                                    color: secondarySelectedColor,
                                  )
                                ],
                              ),
                              Text(
                                "${utils.limitChar(username ?? '-', 7)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: white),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                              Text(
                                _auth.currentUser!.uid == player1Id
                                    ? "${utils.getTranslated(context, "win")} : $win1Count/${widget.round}"
                                    : "${utils.getTranslated(context, "win")} : $win2Count/${widget.round}",
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: white),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Image.asset("assets/images/vs_small.png"),
                          Text(
                            "${utils.getTranslated(context, "draw")} : $tieCount/${widget.round}",
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(color: white),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  widget.imageo,
                                  height: 12,
                                ),
                                Text(
                                  " : ${utils.getTranslated(context, "sign")}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(color: white),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ],
                            ),
                            Text(
                              "${utils.limitChar(widget.oppornentName, 7)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(color: white),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            Text(
                              _auth.currentUser!.uid == player1Id
                                  ? "$win2Count/${widget.round} : ${utils.getTranslated(context, "win")}"
                                  : "$win1Count/${widget.round} : ${utils.getTranslated(context, "win")}",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(color: white),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              "${widget.oppornentPic}",
                            ),
                            radius: 25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getGamebuttons() async {
    DatabaseEvent snap =
        await _gameRef.child(widget.gameKey).child("buttons").once();

    final data = (snap.snapshot.value as List);
    for (var i = 0; i < data.length; i++) {
      buttons.addAll({i: copyDeepMap(data[i])});
    }

    setState(() {});

    // setState(() {
    //   buttons = copyDeepMap(snap.snapshot.value as Map);
    // });
  }
}
