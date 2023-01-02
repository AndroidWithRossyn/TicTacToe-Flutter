import 'dart:async';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/functions/advertisement.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget {
  final String? title;

  const PrivacyPolicy({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<PrivacyPolicy> with TickerProviderStateMixin {
  late String htmlText;

/*  final flutterWebViewPlugin = FlutterWebviewPlugin();
  late StreamSubscription<WebViewStateChanged> _onStateChanged;*/

  @override
  void initState() {
    super.initState();
    Advertisement.loadAd();
    /*flutterWebViewPlugin.close();

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (state.type == WebViewState.abortLoad) {
        _launchSocialNativeLink(state.url);
      }
    });*/
  }

  @override
  void dispose() {
    //_onStateChanged.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.title == utils.getTranslated(context, "privacy"))
      htmlText = privacyText;
    else if (widget.title == utils.getTranslated(context, "termCond"))
      htmlText = termText;
    else if (widget.title == utils.getTranslated(context, "aboutUs"))
      htmlText = aboutText;
    else if (widget.title == utils.getTranslated(context, "contactUs"))
      htmlText = contactText;

    return WillPopScope(
        onWillPop: () async {
        //  if (mounted) Advertisement.showAd();
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(centerTitle: true,
              leading: Container(
                margin: EdgeInsets.all(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              title: Text(
                widget.title!,
                style: TextStyle(color: primaryColor),
              ),
              backgroundColor: white,
            ),
            body: WebView(
                zoomEnabled: true,
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: 'about:blank',
                onWebViewCreated: (WebViewController webViewController) {
                  webViewController.loadHtmlString(htmlText);
                },
              javascriptChannels: <JavascriptChannel>{
                utils.toasterJavascriptChannel(context),
              },
              navigationDelegate: (NavigationRequest request) {
                  launchUrl(Uri.parse(request.url),mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              },
            ))
        );
  }


}
