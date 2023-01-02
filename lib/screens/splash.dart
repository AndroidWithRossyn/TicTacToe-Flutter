import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

Utils utils = new Utils();

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToNextPage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: utils.gradBack(),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/splash_logo.png',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1),
            child: Text(
              utils.getTranslated(context, "CalculateEveryMove"),
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(fontFamily: 'DISPLATTER', color: white),
            ),
          )
        ],
      ),
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void navigateToNextPage() async {
    await MobileAds.instance.initialize();
    await UnityAds.init(
      gameId: gameID,
      testMode: true,
      onComplete: () => print('Initialization Complete'),
      onFailed: (error, message) =>
          print('Initialization Failed: $error $message'),
    );
    music.play(backMusic);

    bool value = await utils.getUserLoggedIn("isLoggedIn");

    if (value) {
      utils.replaceScreenAfter(context, "/home");
    }else{
      utils.replaceScreenAfter(context, "/authscreen");
    }

  }
}
