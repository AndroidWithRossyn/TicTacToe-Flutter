
import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/screens/home_screen.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/material.dart';

class HowToPlay extends StatelessWidget {
  const HowToPlay({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Coin(),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: white,
            image: DecorationImage(
                image: AssetImage(
                  "assets/images/bg.png",
                ),
                fit: BoxFit.fill,)),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                height: MediaQuery.of(context).size.height / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      utils.getTranslated(context, "howToPlayHeading"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.none,
                        color: white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        utils.getTranslated(context, "howToPlayContent"),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: white,decoration: TextDecoration.none,),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 5,
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius:
                          BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 5),
                          child: Text(
                            utils.getTranslated(context, "ok"),
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Image.asset("assets/images/dora_instructor.png")
          ],
        ),
      ),
    );
  }
}
