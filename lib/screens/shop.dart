import 'dart:async';
import 'dart:io';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/string.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/functions/advertisement.dart';
import 'package:TicTacToe/functions/gameHistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';


import 'splash.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        music.play(click);
        return Future.value(true);
      },
      child: const Scaffold(
        body: ShopActivity(),
      ),
    );
  }
}

class ShopActivity extends StatefulWidget {
  const ShopActivity({Key? key}) : super(key: key);

  @override
  _ShopActivityState createState() => _ShopActivityState();
}

class _ShopActivityState extends State<ShopActivity> {
  StreamSubscription? _purchaseUpdatedSubscription;
  StreamSubscription? _purchaseErrorSubscription;
  StreamSubscription? _conectionSubscription;
  late int curItem;

  final List<String> _productLists = Platform.isAndroid
      ? [
          'android.test.purchased',
          'android.test.purchased',
          'android.test.purchased',
          'android.test.purchased',
          'android.test.purchased',
          'android.test.purchased',
        ]
      : [
          'com.coin.point100',
          'com.coin.point500',
          'com.coin.point1000',
          'com.coin.point2000',
          'com.coin.point5000',
          'com.coin.point5000'
        ];



  List<IAPItem> _items = [];

  bool isLoaded = false;
  var ins;

  @override
  void initState() {
    super.initState();

    Advertisement.loadAd();
    initPlatformState();

      getADDisplay().then((value) async {
        if (value) {
          createRewardedAd();
        }
      });
    deleteOldAdLimitData();
  }

  @override
  void dispose() {
    if (_conectionSubscription != null) {
      _conectionSubscription!.cancel();
      _conectionSubscription = null;
    }
    _purchaseUpdatedSubscription!.cancel();
    _purchaseErrorSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: secondaryColor,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/shop_icon.png",
                color: white,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(utils.getTranslated(context, "shop")),
              ),
            ],
          ),
        ),
        body: Container(
            decoration: utils.gradBack(),
            height: double.maxFinite,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40),
              child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0),
                  itemCount: coinList.length,
                  itemBuilder: (context, i) {
                    return item(i);
                  }),
            )));
  }

  Widget item(int i) {
    return InkWell(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(coinList[i].icon),
              Text(
                coinList[i].name,
                style: TextStyle(color: primaryColor),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                coinList[i].desc,
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
      onTap: () async {
        if (coinList[i].name == watchEarn) {
          if (wantGoogleAd) {
            await getADDisplay().then((value) async {
              if (value) {
                print(ins.toString());
                if (ins != null) {
                  if (wantGoogleAd) {
                    ins.show(onUserEarnedReward:
                        (RewardedAd ad, RewardItem reward) async {
                      await updateCoins(adRewardAmount, "Watched ad");

                      FirebaseDatabase db = FirebaseDatabase.instance;
                      var today = time();
                      DatabaseEvent once = await db
                          .ref()
                          .child("adLimit")
                          .child(FirebaseAuth.instance.currentUser!.uid)
                          .child(today)
                          .once();

                      var count = int.parse(once.snapshot.value.toString());

                      await db
                          .ref()
                          .child("adLimit")
                          .child(FirebaseAuth.instance.currentUser!.uid)
                          .update({"$today": count + 1});
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: secondarySelectedColor,
                      content: Text(
                        utils.getTranslated(context, "adNotLoaded"),
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      )));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: secondarySelectedColor,
                    content: Text(
                      utils.getTranslated(context, "youReachedAtTodaysAdLimit"),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )));
              }
            });
          } else {
            await getADDisplay().then((value) async {

              if (value) {
                try {
                  UnityAds.load(
                      placementId: unityRewardAdPlacement(),
                      onComplete: (placementId) {
                        UnityAds.showVideoAd(
                            placementId:unityRewardAdPlacement(),
                            onComplete: (placementId)async {

                              await updateCoins(adRewardAmount, "Watched ad");

                              FirebaseDatabase db = FirebaseDatabase.instance;
                              var today = time();
                              DatabaseEvent once = await db
                                  .ref()
                                  .child("adLimit")
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .child(today)
                                  .once();

                              var count = int.parse(once.snapshot.value.toString());

                              await db
                                  .ref()
                                  .child("adLimit")
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .update({"$today": count + 1});

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: secondarySelectedColor,
                                  content: Text(
                                    utils.getTranslated(context, "rewardAmountAddedSuccessfully"),
                                    style: TextStyle(
                                        color: Colors.black, fontWeight: FontWeight.bold),
                                  )));
                            },// loadAd(),
                            onFailed: (placementId, error, message) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: secondarySelectedColor,
                                  content: Text(
                                    "error while loading ad",
                                    style: TextStyle(
                                        color: Colors.black, fontWeight: FontWeight.bold),
                                  )));
                            },
                            onStart: (placementId) =>
                                print('Video Ad $placementId started'),
                            onClick: (placementId) => print('Video Ad $placementId click'),
                            onSkipped: (placementId) {

                            }      );
                      },
                      onFailed: (placementId, error, message) =>
                          print('Failed to load Unity ad $message')
                  );
                }catch (e){

              }

              }else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: secondarySelectedColor,
                    content: Text(
                      utils.getTranslated(context, "youReachedAtTodaysAdLimit"),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )));
              }
            });

          }
        } else {
          IAPItem item = _items[i];
          curItem = i;
          this._requestPurchase(item);
        }
      },
    );
  }

  purchased(coins) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                  utils.getTranslated(context, "congratulations"),
                style: TextStyle(color: white),
              ),
            ),
            backgroundColor: primaryColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text("You got $coins",
                textAlign: TextAlign.center, style: TextStyle(color: white)),
          );
        });
  }

  updateCoins(int reward, String status) async {
    FirebaseDatabase fb = FirebaseDatabase.instance;
    DatabaseEvent coin = await fb
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("coin")
        .once();
    var newCoin = int.parse(coin.snapshot.value.toString() )+ reward;
    fb
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .update({"coin": newCoin});

    History().update(
        date: DateTime.now().toString(),
        gotcoin: reward,
        status: status,
        type: "AD",
        gameid: "notfind",
        oppornentId: "",
        uid: FirebaseAuth.instance.currentUser!.uid);
  }

  createRewardedAd() async {
    if (wantGoogleAd) {
      MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ["76E93F010B591E281F371BEB6B05C0E0"]));
      RewardedAd.load(
          adUnitId: rewardedAdID,
          request: AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {

              print("ad is ${ad.responseInfo}");
              setState(() {
                isLoaded = true;
                ins = ad;
              });
            },
            onAdFailedToLoad: (LoadAdError error) {

              print("failed to load $error");
            },
          ));
    }
  }

  String time() {
    DateTime date = DateTime.now();
    int year = date.year;
    int month = date.month;
    int day = date.day;
    return "$day$month$year";
  }

  //method for daily ad limit
  Future<bool> getADDisplay() async {
    FirebaseDatabase db = FirebaseDatabase.instance;

    var today = time();
    DatabaseEvent once = await db
        .ref()
        .child("adLimit")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(today)
        .once();


    var count = once.snapshot.value.toString();

    if (count == "null") {
      await db
          .ref()
          .child("adLimit")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .update({"$today": 0});

      return true;
    } else {
       int count = int.parse(once.snapshot.value.toString());

      if (count < adLimit) {
        return true;
      } else {
        return false;
      }
    }
  }

  String unityRewardAdPlacement() {
    if (Platform.isAndroid) {
      return "Rewarded_Android";
    }
    if (Platform.isIOS) {
      return "Rewarded_iOS";
    }
    return "";
  }

  void _requestPurchase(IAPItem item) {
    FlutterInappPurchase.instance.requestPurchase(item.productId!);
  }

  Future _getProduct() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      this._items.add(item);
    }

    setState(() {
      this._items = items;
    });
  }

  Future<void> initPlatformState() async {
    // prepare
    await FlutterInappPurchase.instance.initialize();

    // refresh items for android
    try {
      await (FlutterInappPurchase.instance.consumeAll()
          as FutureOr<String?>);
    } catch (err) {}

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {});

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      int coin = int.parse(coinList[curItem].name.split(" ")[0]);
      await updateCoins(coin, "Coin Purchased");

      if (mounted) {
        purchased(coinList[curItem].name);
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {});

    _getProduct();
  }

  void deleteOldAdLimitData() async {
    Map? adValues = new Map();
    FirebaseDatabase db = FirebaseDatabase.instance;
    var today = time();
    DatabaseEvent once = await db
        .ref()
        .child("adLimit")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once();

    if (once.snapshot.value != null) {
      adValues = once.snapshot.value as Map;
      adValues.forEach((key, value) {
        if (today != key) {
          FirebaseDatabase.instance
              .ref()
              .child("adLimit")
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child(key)
              .remove();
        }
      });
    }
  }
}
