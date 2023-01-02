import 'package:TicTacToe/screens/login.dart';
import 'package:TicTacToe/screens/gamehistory.dart';
import 'package:TicTacToe/screens/home_screen.dart';
import 'package:TicTacToe/screens/leaderboard.dart';
import 'package:TicTacToe/screens/profile.dart';
import 'package:TicTacToe/screens/shop.dart';
import 'package:TicTacToe/screens/skins.dart';
import 'package:TicTacToe/screens/splash.dart';

class Routes {
  static final data = {
    "/authscreen": (context) => Login(),
    "/home": (context) => HomeScreenActivity(),
    "/splash": (context) => SplashScreen(),
    "/leaderboard": (context) => LeaderBoardScreen(),
    "/profile": (context) => Profile(),
    "/shop": (context) => ShopScreen(),
    "/skin": (context) => Skins(),
    "/gamehistory": (context) => GameHistory(),
  };
}
