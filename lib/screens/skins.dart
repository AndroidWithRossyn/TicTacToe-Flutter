import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/string.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/functions/advertisement.dart';
import 'package:TicTacToe/functions/dialoges.dart';
import 'package:TicTacToe/functions/gameHistory.dart';
import 'package:TicTacToe/functions/getCoin.dart';
import 'package:TicTacToe/widgets/alertDialoge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'splash.dart';

class Skins extends StatefulWidget {
  const Skins({Key? key}) : super(key: key);

  @override
  _SkinsState createState() => _SkinsState();
}

class _SkinsState extends State<Skins> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference dbRef =  FirebaseDatabase.instance.ref();
  late DatabaseEvent usersSkinData;

  List<Map?> purchasedSkin = [];
  late String userId;

  final skinData = <Widget>[];

  @override
  void initState() {
    super.initState();
    Advertisement.loadAd();
    fillUserDetails();
  }

  void fillUserDetails() async {
    purchasedSkin.clear();
    userId = _auth.currentUser!.uid;
    usersSkinData = await dbRef.child("userSkins").child(userId).once();
    Map? map = usersSkinData.snapshot.value as Map;
    if (usersSkinData.snapshot.value != null) {
      map.keys.forEach((element) {
        purchasedSkin.add(map[element]);
      });
    }
    setState(() {});
  }

  getChildren() {
    skinData.clear();
    if (userSkin.isNotEmpty) {
      userSkin.forEach((key, value) {
        bool isSkinPurchased = false;
        bool isSkinActive = false;

        for (int i = 0; i < purchasedSkin.length; i++) {
          if (key == purchasedSkin[i]!['itemid'] &&
              value['userSkin'] == purchasedSkin[i]!['itemx'] &&
              value['opponentSkin'] == purchasedSkin[i]!['itemo']) {
            isSkinPurchased = true;
            if (purchasedSkin[i]!['selectedStatus'] == "Active") {
              isSkinActive = true;
            }
          }
        }

        skinData.add(getSkin(key, value['userSkin'], value['opponentSkin'],
            value['price'], isSkinPurchased, isSkinActive));
      });
    } else {
      skinData.add(getSkin("DORA Classic", "assets/images/cross_skin.png",
          "assets/images/circle_skin.png", 0, true, true));
    }
    return skinData;
  }

  getSkin(String name, String userSkin, String opponentSkin, int? price,
      bool isSkinPurchased, bool isSkinSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              height: 70,
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(4, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Image.asset(
                      userSkin,
                      height: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      child: Image.asset(
                        opponentSkin,
                        height: 20,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(4, 4), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          InkWell(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.20,
              height: 70,
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  color: red,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  price == 0
                      ? Column(
                          children: [
                            Text(utils.getTranslated(context, "free")),
                            isSkinSelected
                                ? Text(
                                    utils.getTranslated(
                                        context, "currentlyUsing"),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    utils.getTranslated(context, "useNow"),
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  )
                          ],
                        )
                      : isSkinPurchased == true
                          ? Container(
                              child: isSkinSelected
                                  ? Text(
                                      utils.getTranslated(
                                          context, "currentlyUsing"),
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      utils.getTranslated(context, "useNow"),
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                            )
                          : Container(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/coin_symbol.png",
                                        height: 14,
                                      ),
                                      Text(
                                        " ${price.toString()}",
                                        style: TextStyle(
                                            color: white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    utils.getTranslated(context, "buyNow"),
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                ],
              ),
            ),
            onTap: () async {
              music.play(click);
              var ins = GetUserInfo();
              var usersCoin = await (await ins.getCoin());
              if (usersCoin < price && isSkinPurchased == false) {
                Dialoge.lessMoney(context);
              } else if (isSkinPurchased == false) {
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
                                await purchaseSkin(
                                    name, userSkin, opponentSkin, price!);
                                fillUserDetails();
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: Text(utils.getTranslated(context, "yes"),
                                  style: TextStyle(color: white))),
                          TextButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(color)),
                              onPressed: () async {
                                music.play(click);
                                Navigator.pop(context);
                              },
                              child: Text(utils.getTranslated(context, "no"),
                                  style: TextStyle(color: white)))
                        ],
                      );
                    });
              } else if (isSkinPurchased == true && isSkinSelected == false) {
                Map map = usersSkinData.snapshot.value as Map;

                map.forEach((key, value) {
                  Utils localValue = Utils();
                  localValue.setSkinValue("user_skin", userSkin);
                  localValue.setSkinValue("opponent_skin", opponentSkin);

                  if (value['itemid'] == name) {
                    dbRef
                        .child("userSkins")
                        .child(userId)
                        .child(key)
                        .update({"selectedStatus": "Active"});
                  } else {
                    dbRef
                        .child("userSkins")
                        .child(userId)
                        .child(key)
                        .update({"selectedStatus": "Deactive"});
                  }
                });
                fillUserDetails();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> purchaseSkin(String name, String userSkinImagePath,
      String opponentSkinImagePath, int price) async {
    //add purchased skin to database
    dbRef.child("userSkins").child(_auth.currentUser!.uid).push().set({
      "itemid": name,
      "itemo": opponentSkinImagePath,
      "itemx": userSkinImagePath,
      "selectedStatus": "Deactive"
    });

    //Deduct purchasedPrice of skin from Total Coin
    var totalcoin = await dbRef
        .child("users")
        .child(_auth.currentUser!.uid)
        .child("coin")
        .once();
    var updatedCoin = int.parse(totalcoin.snapshot.value.toString()) - price;
    dbRef
        .child("users")
        .child(_auth.currentUser!.uid)
        .update({"coin": updatedCoin});

    //add coin debit transaction to history
    History().update(
        uid: FirebaseAuth.instance.currentUser!.uid,
        date: "${DateTime.now().toString()}",
        gotcoin: -price,
        oppornentId: "",
        status: "Skin Purchased",
        type: "Skin Purchased",
        gameid: "");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        music.play(click);
        //Advertisement.showAd();
        return Future.value(true);
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/skin_icon.png",
                color: white,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("${utils.getTranslated(context, "skins")}"),
              ),
            ],
          ),
          backgroundColor: secondaryColor,
          elevation: 0,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: utils.gradBack(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListView(children: [...getChildren()]),
          ),
        ),
      ),
    );
  }
}
