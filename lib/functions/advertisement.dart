import 'dart:io';

import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class Advertisement {

  static loadAd() {
    if (wantGoogleAd) {

      InterstitialAd.load(
          adUnitId: interstitialAdID,
          request: AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (InterstitialAd ad) {
                interstitialAd = ad;
                Advertisement.showAd();
              },
              onAdFailedToLoad: (LoadAdError err) {}));
    } else {

      UnityAds.load(
          placementId: Advertisement().unityInterstitialPlacement(),
          onComplete: (placementId) {
           showAd();
          },
          onFailed: (placementId, error, message) =>
              print('Failed to load Unity ad $message')
      );

    }
  }

  static showAd() {
    if (wantGoogleAd) {
      if (interstitialAd != null) {
        interstitialAd!.show();
      } else {
        loadAd();
      }
    } else {
      UnityAds.showVideoAd(
        placementId:Advertisement().unityInterstitialPlacement(),
        onComplete: (placementId) {},// loadAd(),
        onFailed: (placementId, error, message) =>
            print('Video Ad $placementId failed: $error $message'),
        onStart: (placementId) =>
            print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) {}      );
    }
  }

  String unityInterstitialPlacement() {
    if (Platform.isAndroid) {
      return "Interstitial_Android";
    }
    if (Platform.isIOS) {
      return "Interstitial_iOS";
    }
    return "";
  }
}

