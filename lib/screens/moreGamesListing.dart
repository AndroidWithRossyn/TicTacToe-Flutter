import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/screens/moreGames.dart';

import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Helper/utils.dart';
import '../functions/advertisement.dart';

class MoreGamesListing extends StatefulWidget {
  MoreGamesListing({Key? key}) : super(key: key);

  @override
  State<MoreGamesListing> createState() => _MoreGamesListingState();
}

class _MoreGamesListingState extends State<MoreGamesListing> {
  final List<Widget> gameListUI = [];

  List<HTMLGames> gamesList = [
    HTMLGames(
        gameImage:
        'https://firebasestorage.googleapis.com/v0/b/tictact-a37a5.appspot.com/o/More%20game%20images%2Fhextris.webp?alt=media&token=302e901c-6c88-478f-bb0b-2736ed6e34ab',
        gameName: 'Hextris',
        gameURL: 'https://hextris.io/'),

    HTMLGames(
        gameImage:
        'https://firebasestorage.googleapis.com/v0/b/tictact-a37a5.appspot.com/o/More%20game%20images%2Fclumsy-bird-open-source-game.webp?alt=media&token=344ad51f-4ca5-40ae-b71e-0a863f51e9d4',
        gameName: 'Clumsy Bird',
        gameURL: 'https://ellisonleao.github.io/clumsy-bird/'),
    HTMLGames(
        gameImage:
        'https://firebasestorage.googleapis.com/v0/b/tictact-a37a5.appspot.com/o/More%20game%20images%2Fpacman-html5-canvat.webp?alt=media&token=94941943-d863-4dbf-9467-a7fb53819c3f',
        gameName: 'Pacman',
        gameURL: 'https://pacman.platzh1rsch.ch/'),
  ];

  @override
  void initState() {
   Advertisement.loadAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.games,
              size: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("${utils.getTranslated(context, "playMoreGames")}"),
            ),
          ],
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
      ),
      backgroundColor: secondaryColor,
      body: gamesList.isEmpty
          ? Center(
              child: Text(utils.getTranslated(context, "noMoreGamesFound")),
            )
          : showMoreGameList(context),
    );
  }

  Widget showMoreGameList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        children: [...getMoreGameList(context)],
      ),
    );
  }

  getMoreGameList(BuildContext context) {
    gameListUI.clear();
    gamesList.forEach((element) {
      gameListUI.add(getGame(element, context));
    });
    return gameListUI;
  }

  Widget getGame(HTMLGames game, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              // padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              height: 70,
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                    child: Container(
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
                      child: FadeInImage(
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          game.gameImage,
                        ),
                        placeholder: AssetImage(
                          'assets/images/dora_placeholder.png',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          game.gameName,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2),
                        ),
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
                child: Center(
                    child: Text(
                  utils.getTranslated(context, 'playNow'),
                ))),
            onTap: () async {
              music.play(click);
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PlayGame(gameURL: game.gameURL),
                  ));
            },
          ),
        ],
      ),
    );
  }
}

class HTMLGames {
  final String gameName;
  final String gameImage;
  final String gameURL;

  HTMLGames(
      {required this.gameName, required this.gameImage, required this.gameURL});
}
