import 'dart:io';

import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';



class PlayGame extends StatefulWidget {
  String gameURL;
  PlayGame({Key? key,required this.gameURL}) : super(key: key);

  @override
  State<PlayGame> createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayGame> {

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
              zoomEnabled: true,
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: widget.gameURL,
              onWebViewCreated: (WebViewController webViewController) {

              },
            onProgress: (progress){

            },
            javascriptChannels: <JavascriptChannel>{
              utils.toasterJavascriptChannel(context),
            },
            navigationDelegate: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
          Platform.isIOS ?
          Positioned.directional(textDirection: Directionality.of(context),
              start: 5.0,top: 10.0,
              child: Container(
                height: 35,width: 35,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10)),
                child: FittedBox(
                  child: IconButton(
                    onPressed: (){Navigator.pop(context);},
                    icon: Icon(Icons.arrow_back_ios_outlined,size: 30),

                  ),
                ),
              )) :Container()
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
