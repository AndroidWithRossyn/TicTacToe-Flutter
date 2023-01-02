import 'dart:async';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/string.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/functions/dialoges.dart';
import 'package:TicTacToe/functions/findGame.dart';
import 'package:TicTacToe/functions/getCoin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'multiplayer.dart';
import 'splash.dart';

class FindingPlayerScreen extends StatefulWidget {
  final int? selected;
  final int? round;

  FindingPlayerScreen({this.selected, this.round});

  @override
  _FindingPlayerScreenState createState() => _FindingPlayerScreenState();
}

class _FindingPlayerScreenState extends State<FindingPlayerScreen>
    with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseDatabase _ins = FirebaseDatabase.instance;
  String? _profilePic;
  String? _displayName;
  String? _opporentName;
  String? _opporentPic;
  String? firstTry;
  String? opponentPlayerName;
  String? _temp = "";
  int count = 30;
  String? gameKey = "";
  var ins = GetUserInfo();
  Timer? t, oppTimer;
  var firstuid;

  StreamSubscription<DatabaseEvent>? listen;
  late ValueNotifier oppositPlayerName;
  late ValueNotifier keyOfGame;
  bool canPlayGame = false;
  bool isplaying = false;
  bool canUpdateUi = false;
  bool isCoinAndCountValueUpdated = false;
  String oppMsg = findingOpp,
      img = "assets/images/dora_findopponent.png",
      btnTxt = "Cancel";
  String? imagex, imageo;
  late DatabaseReference _userSkinRef;

  @override
  void initState() {
    super.initState();
    oppositPlayerName = ValueNotifier("");
    keyOfGame = ValueNotifier("");

    _userSkinRef = _ins.ref().child("userSkins");

    getFieldValue("profilePic", (e) => _profilePic = e, (e) => _profilePic = e);
    getFieldValue("username", (e) => _displayName = e, (e) => _displayName = e);

    findGame();
    getImage();

    Future.delayed(const Duration(seconds: 0)).then((value) {
      opponentPlayerName = utils.getTranslated(context, "waitForOpponent");
    });
    oppTimer = Timer(const Duration(seconds: 60), () {
      setState(() {

        if (_temp != null) {
          Dialoge.removeChild("Game", _temp);
        }
        oppMsg = utils.getTranslated(context, "notFoundOpp");
        opponentPlayerName = utils.getTranslated(context, "noOpponentOnline");
        img = "assets/images/dora_noopponent.png";
        btnTxt = utils.getTranslated(context, "tryAgain");
      });
    });
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

  Future<void> getImage() async {
    DatabaseEvent userSkins =
        await _userSkinRef.child(FirebaseAuth.instance.currentUser!.uid).once();
    Map map =  userSkins.snapshot.value as Map;

    map.forEach((key, value) {
      if (value["selectedStatus"] == "Active") {
        setState(() {
          imagex = value["itemx"].toString();
          imageo = value["itemo"].toString();
        });
        return;
      }
    });


    setState(() {});
  }

//get opponent user details
  oppornentDetails(String key) async {
    DatabaseEvent oppornentDetail = await _ins
        .ref()
        .child("users")
        .child(key)
        .once()
        .catchError((e) {});
    return oppornentDetail.snapshot.value;
  }


  findGame() async {


    //--this method will create or join game if there are any game available then it will join otherwise it will create new game
    FindGame()
      ..joinGame(widget.selected, widget.round).then((Map data) async {
        //--if game created


        if (data['JoinStatus'] == JoinStatus.created) {
          _temp = data["roomKey"];

          //change listener
          listen = _ins
              .ref()
              .child("Game")
              .child(data["roomKey"])
              .onChildChanged
              .listen((DatabaseEvent ev) async {
            if (ev.snapshot.key == "status" &&
                ev.snapshot.value != "closed" &&
                ev.snapshot.value != "pending") {
              //--update coin value oldcoin-entryamount
              //
              if (isCoinAndCountValueUpdated == false) {
                //temp: await updateCoinAndCount();
                isCoinAndCountValueUpdated = true;
              }
              //--
              //--fetch oppornent details
              DatabaseEvent _player2snap = await _ins
                  .ref()
                  .child("Game")
                  .child(data["roomKey"])
                  .child("player2")
                  .once();

              if (_player2snap.snapshot.value != null) {
                var _snapkey = (_player2snap.snapshot.value as Map)["id"];


                var oppornentDetail = await oppornentDetails(_snapkey);
                var getFirstTry = await _ins
                    .ref()
                    .child("Game")
                    .child(data["roomKey"])
                    .once();
                firstTry = (getFirstTry.snapshot.value as Map)["try"];

                var getFirstTryId = await _ins
                    .ref()
                    .child("Game")
                    .child(data["roomKey"])
                    .child(firstTry!)
                    .child("id")
                    .once();

                firstuid = getFirstTryId.snapshot.value;


                _opporentName = oppornentDetail["username"];

                oppositPlayerName.value = _opporentName;
                oppositPlayerName.notifyListeners();
                _opporentPic = oppornentDetail["profilePic"];
                gameKey = data["roomKey"];
                keyOfGame.value = data["roomKey"];
                keyOfGame.notifyListeners();

                oppMsg = utils.getTranslated(context, "foundOpp");
                img = "assets/images/dora_oppentfind.png";
                btnTxt = utils.getTranslated(context, "cancel");
                if (mounted) setState(() {});
              }
            }
          });
        }
        if (data['JoinStatus'] == JoinStatus.joined) {
          //--opponent details
          var details = await oppornentDetails(data["oppornentKey"]);
//--
          var getFirstTry = await _ins
              .ref()
              .child("Game")
              .child(data["roomKey"])
              .once();
          firstTry = (getFirstTry.snapshot.value as Map)["try"];

          var getFirstTryId = await _ins
              .ref()
              .child("Game")
              .child(data["roomKey"])
              .child(firstTry!)
              .child("id")
              .once();

          firstuid = getFirstTryId.snapshot.value;


          await Future.delayed(Duration(seconds: 1));
          if (details != null) {
            _opporentName = details["username"];
            _opporentPic = details["profilePic"];
            gameKey = data["roomKey"];
            oppositPlayerName.value = _opporentName;
            keyOfGame.value = data["roomKey"];
            keyOfGame.notifyListeners();
            oppositPlayerName.notifyListeners();

            // setState(() {});
          }

          setState(() {});
        }
        if (data['JoinStatus'] == JoinStatus.pending) {
          findGame();
        }
      });
  }

  updateCoinMinus() async {

    DatabaseEvent coinOld =
    await _ins.ref().child("users").child(_auth.currentUser!.uid).once();
    var fin = (coinOld.snapshot.value as Map)["coin"] - widget.selected;
    _ins.ref().child("users").child(_auth.currentUser!.uid).update({"coin": fin});
    //--
  }

  changeScreen(context) {
    //FindGame.disposes();

      updateCoinMinus();

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) {
        return MultiplayerScreen(
          oppornentName: _opporentName,
          oppornentPic: _opporentPic,
          gameKey: gameKey,
          firstTry: _auth.currentUser!.uid == firstuid,
          round: widget.round,
          imageo: imageo,
          imagex: imagex,
        );
      }));
    });
  }

  canPlay(key) async {

    var _player1 =
        await _ins.ref().child("Game").child(key).child("player1").once();
    var _player2 =
        await _ins.ref().child("Game").child(key).child("player2").once();

    var player1 = (_player1.snapshot.value as Map)["id"];
    var player2 = (_player2.snapshot.value as Map)["id"];


    if (player1 == FirebaseAuth.instance.currentUser!.uid ||
        player2 == FirebaseAuth.instance.currentUser!.uid) {
      oppositPlayerName.notifyListeners();
      canUpdateUi = true;
      changeScreen(context);
    } else {
      canUpdateUi = false;
      findGame();
      // Navigator.pop(context);
    }
    setState(() {});
  }

  @override
  void dispose() {
    t?.cancel();
    oppTimer?.cancel();

    listen?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isplaying == false && oppositPlayerName.value != '') {
      canPlay(keyOfGame.value);
      isplaying = true;
    }

    return WillPopScope(
        onWillPop: () async {
          if (_temp != "") {
            Dialoge.removeChild("Game", _temp);
          }

          await music.play(click);
          return Future.value(true);
        },
        child: Scaffold(
            body: Container(
                decoration: utils.gradBack(),
                child: Column(
                  children: [
                    //find opponent image
                    Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(img),
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: Text(oppMsg),
                            ),
                          ],
                        )),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        //players profile pic
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                      height: 80.0,
                                      width: 80.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: white,
                                          )),
                                      child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor: secondaryColor,
                                              backgroundImage: _profilePic == null ?
                                                  null
                                                  :
                                                  NetworkImage(_profilePic!)))),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Image.asset(
                                    "assets/images/vs_iconbig.png")),
                            Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 80.0,
                                      width: 80.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: white,
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: CircleAvatar(
                                            radius: 50,
                                            backgroundColor: back,
                                            backgroundImage: oppositPlayerName
                                                            .value !=
                                                        "" &&
                                                    canUpdateUi == true
                                                ? NetworkImage("$_opporentPic")
                                                : null,
                                            child: oppositPlayerName.value !=
                                                        "" &&
                                                    canUpdateUi == true
                                                ? null
                                                : Center(
                                                    child: Text(
                                                    "?",
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: primaryColor),
                                                  ))),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                        //players name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 10.0),
                                  child: Text(
                                    "$_displayName \n",
                                    style: TextStyle(color: white),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4.5,
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0, top: 10.0),
                                child: Text(
                                  oppositPlayerName.value != "" &&
                                          canUpdateUi == true
                                      ? "${oppositPlayerName.value} \n"
                                      : "$opponentPlayerName \n",
                                  style: TextStyle(color: white),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: back),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      btnTxt == utils.getTranslated(context, "tryAgain")? Icons.replay_circle_filled
                                          : Icons.cancel,
                                      color: primaryColor,
                                    ),
                                    Text(
                                      btnTxt,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(color: primaryColor),
                                    ),
                                  ],
                                )),
                            onPressed: () {
                              if (btnTxt == utils.getTranslated(context, "tryAgain")) {
                                setState(() {
                                  oppMsg = utils.getTranslated(context, "findingOpp");
                                  opponentPlayerName = utils.getTranslated(context, "waitForOpponent");
                                  img = "assets/images/dora_findopponent.png";
                                  btnTxt = "Cancel";
                                });
                                findGame();
                                oppTimer!.cancel();
                                oppTimer = Timer(Duration(seconds: 60), () {
                                  if (_temp != null) {
                                    Dialoge.removeChild("Game", _temp);
                                  }
                                  setState(() {
                                    oppMsg = utils.getTranslated(context, "notFoundOpp");
                                    opponentPlayerName =
                                    utils.getTranslated(context, "noOpponentOnline");
                                    img = "assets/images/dora_noopponent.png";
                                    btnTxt = utils.getTranslated(context, "tryAgain");
                                  });
                                });
                              } else if (btnTxt == utils.getTranslated(context, "cancel")) {
                                if (_temp != "") {
                                  FirebaseDatabase.instance.ref().child("Game").child(_temp!).update({"status": "closed"});
                                  Dialoge.removeChild("Game", _temp);
                                }
                                oppTimer!.cancel();
                                Navigator.pop(context);
                              }
                            }),
                      ],
                    ),
                  ],
                ))));
  }
}
