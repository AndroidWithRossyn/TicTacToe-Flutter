import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/screens/offline_play.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectLevelDialog extends StatefulWidget {
  final String userSkin, opponentSkin;
  SelectLevelDialog(
      {Key? key, required this.opponentSkin, required this.userSkin})
      : super(key: key);

  @override
  State<SelectLevelDialog> createState() => _SelectLevelDialogState();
}

class _SelectLevelDialogState extends State<SelectLevelDialog> {
  int selectedLevelIndex = 0;

  Widget _buildLevelContainer(
      {required String levelName, required int levelIndex}) {
    return GestureDetector(
      onTap: () async {
        music.play(dice);
        setState(() {
          selectedLevelIndex = levelIndex;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: selectedLevelIndex == levelIndex
                ? secondarySelectedColor
                : back,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(
              child: Text(
                utils.getTranslated(context, levelName),
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: primaryColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: Center(
        child: Text(
          utils.getTranslated(context, "selectLevel"),
          style: Theme.of(context).textTheme.subtitle2!.copyWith(color: white),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: typeOfLevel
              .map((e) => _buildLevelContainer(
                  levelName: e, levelIndex: typeOfLevel.indexOf(e)))
              .toList(),
        ),
      ),
      actions: [
        ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(back),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))))),
            onPressed: () async {
              music.play(click);
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => SinglePlayerScreenActivity(
                          widget.userSkin,
                          widget.opponentSkin,
                          selectedLevelIndex)));
            },
            icon: Icon(
              Icons.skip_next,
              color: primaryColor,
              size: 20,
            ),
            label: Text(
              utils.getTranslated(context, "next"),
              style: TextStyle(color: primaryColor, fontSize: 12),
            ))
      ],
    );
  }
}
