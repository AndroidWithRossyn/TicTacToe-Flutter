import 'package:TicTacToe/Helper/demo_localization.dart';
import 'package:TicTacToe/routes/routes.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:TicTacToe/widgets/life_cycle_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Helper/color.dart';
import 'Helper/constant.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
   await Firebase.initializeApp();

  //await MobileAds.instance.initialize();


  runApp(
    MyApp()
  );
}

class MyApp extends StatefulWidget {

   MyApp({Key? key}) : super(key: key);

  late SharedPreferences sharedPreferences;

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale? _locale;
  setLocale(Locale locale) {

    if (mounted)
      setState(() {
        _locale = locale;
      });
  }

  @override
  void didChangeDependencies() {
    utils.getLocale().then((locale) {

      if (mounted)
        setState(() {
          this._locale = locale;
        });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LifeCycleManager(
        child: MaterialApp(
          locale: _locale,
          supportedLocales: [
            Locale("en", "US"),
            Locale("es", "ES"),
            Locale("hi", "IN"),
            Locale("ar", "DZ"),
            Locale("ru", "RU"),
            Locale("ja", "JP"),
            Locale("de", "DE")
          ],
          localizationsDelegates: [
            DemoLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          title: appName,
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          theme: ThemeData(
            fontFamily:  'Poppins',
            textTheme: const TextTheme(
              bodyText1: TextStyle(),
              bodyText2: TextStyle(),
            ).apply(
              bodyColor: white,
              displayColor: white,
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            primaryColor: primaryColor,
            colorScheme: ColorScheme.fromSwatch().copyWith(secondary: secondaryColor),
          ),
          routes: Routes.data,
        ),
      ),
    );
  }
}

  @override
  State<StatefulWidget> createState() {

    throw UnimplementedError();
  }

