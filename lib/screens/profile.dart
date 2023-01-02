import 'dart:async';
import 'dart:io';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/string.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/functions/dialoges.dart';
import 'package:TicTacToe/functions/getCoin.dart';
import 'package:TicTacToe/functions/playbgm.dart';
import 'package:TicTacToe/main.dart';
import 'package:TicTacToe/screens/how_to_play.dart';
import 'package:TicTacToe/screens/login_with_email.dart';
import 'package:TicTacToe/screens/moreGamesListing.dart';

import 'package:TicTacToe/screens/privacy_policy.dart';
import 'package:TicTacToe/widgets/alertDialoge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gamehistory.dart';
import 'splash.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<Profile> {
  int? coin = 0;
  int? matchPlayedCount = 0;
  int? score = 0;
  int? matchWon = 0;
  int? selectedLanguage;
  bool sound = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final InAppReview _inAppReview = InAppReview.instance;
  Utils localValue = Utils();
  late String platform;
  String profilePic = guestProfilePic, username = "", name = "";

  List<String?> languageList = [];
  var imageFile;
  File? _imageFile;
  final picker = ImagePicker();
  bool isLoading = false;
  final _nameFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      platform = "Android";
    }
    if (Platform.isIOS) {
      platform = "IOS";
    }
    getSound();
    getFieldValue("matchplayed", (e) => matchPlayedCount = e,
            (e) => matchPlayedCount = e);
    getFieldValue("coin", (e) => coin = e, (e) => coin = e);
    getFieldValue("score", (e) => score = e, (e) => score = e);
    getFieldValue("matchwon", (e) => matchWon = e, (e) => matchWon = e);
    getFieldValue("profilePic", (e) => profilePic = e, (e) => profilePic = e);
    getFieldValue("username", (e) => username = e, (e) => username = e);

    Future.delayed(Duration.zero, () {
      _getLanguageList();


      _getSavedLanguage();
    });
  }

  getFieldValue(
      String fieldName,
      void Function(dynamic count) callback,
      void Function(dynamic count) update,
      ) async {
    var init;
    try {
      var ins = GetUserInfo();
      init = await (await ins.getFieldValue(fieldName));
      if (mounted) {
        setState(() {
          if (callback != null) callback(init);
        });
      }

      await ins.detectChange(fieldName, (val) {
        if (mounted) {
          if (isLoading) {
            isLoading = false;
          }
          setState(() {
            update(val);
          });
        }
      });
    } catch (err) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
    appStoreId: appStoreId,
    microsoftStoreId: 'microsoftStoreId',
  );

  @override
  Widget build(BuildContext context) {
    _getLanguageList();
    var height = MediaQuery.of(context).padding.top;
    return WillPopScope(
        onWillPop: () async {
          music.play(click);
          return Future.value(true);
        },
        child: Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height / 4.5,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    secondaryColor,
                                    primaryColor,
                                  ]),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40)))),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: height + 10),
                              child: Text("${utils.limitChar(username)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                      color: white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Text(
                                _auth.currentUser!.email == null
                                    ? ""
                                    : "${_auth.currentUser!.email}",
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: white)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/coin_symbol.png",
                                ),
                                Text(
                                  "  $coin",
                                  style: TextStyle(color: white),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned.directional(
                          textDirection: Directionality.of(context),
                          top: height + 3,
                          start: 3,
                          child: IconButton(
                            onPressed: () {
                              music.play(click);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: white,
                              size: 25,
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .22 - 55),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$matchPlayedCount",
                                    style: TextStyle(color: white),
                                  ),
                                  Text(
                                    utils.getTranslated(
                                        context, "matchPlayed"),
                                  ),
                                ],
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$matchWon",
                                    style: TextStyle(color: white),
                                  ),
                                  Text(
                                    utils.getTranslated(
                                        context, "matchWonLbl"),
                                  ),
                                ],
                              ),
                              flex: 1,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ListView(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              // margin: EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: sound ? primaryColor : white,
                                            borderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                                "assets/images/soundon_dark.png",
                                                color: sound
                                                    ? white
                                                    : primaryColor),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                utils.getTranslated(
                                                    context, "soundOn"),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    color: sound
                                                        ? white
                                                        : primaryColor),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      onTap: () async {
                                        changeValue(true);
                                        music.play(click);
                                        setState(() {
                                          sound = true;
                                        });
                                        if (Music.status != null &&
                                            Music.status == "playing") {
                                        } else {
                                          await music.play(backMusic);
                                        }
                                      },
                                    ),
                                    InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: sound ? white : primaryColor,
                                            borderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                                "assets/images/soundoff_dark.png",
                                                color: sound
                                                    ? primaryColor
                                                    : white),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                utils.getTranslated(
                                                    context, "soundOff"),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    color: sound
                                                        ? primaryColor
                                                        : white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        if (Music.status != null &&
                                            Music.status == "playing") {
                                          await music.stop();
                                        }
                                        changeValue(false);
                                        setState(() {
                                          sound = false;
                                        });
                                      },
                                    ),
                                  ],
                                )),
                          ),
                          getTile(utils.getTranslated(context, "history"),
                              "assets/images/history_icon.png"),
                          if (!_auth.currentUser!.isAnonymous) ...[
                            getTile(utils.getTranslated(context, "shop"),
                                "assets/images/shop_icon.png"),
                            getTile(utils.getTranslated(context, "skin"),
                                "assets/images/skin_icon.png"),
                          ],
                          if (_auth.currentUser!.isAnonymous) ...[
                            InkWell(
                              onTap: () async {
                                music.play(click);
                                Navigator.push(context, CupertinoPageRoute(builder: (context) => LoginWithEmail()));
                              },
                              child: ListTile(
                                leading: Icon(
                                  Icons.login,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                title: Text(
                                  utils.getTranslated(context, "signInNow"),
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                          getTile(
                              utils.getTranslated(context, "changeLanguage"),
                              ""),
                          getTile(
                              utils.getTranslated(context, "playMoreGames"),
                              ""),
                          getTile(utils.getTranslated(context, "contactUs"),
                              "assets/images/contactus_icon.png"),
                          getTile(utils.getTranslated(context, "aboutUs"),
                              "assets/images/aboutus_icon.png"),
                          getTile(utils.getTranslated(context, "termCond"),
                              "assets/images/termscond_icon.png"),
                          getTile(utils.getTranslated(context, "privacy"),
                              "assets/images/privacypolicy_icon.png"),
                          getTile(
                              utils.getTranslated(context, "howToPlayHeading"),
                              "assets/images/help_icon.png"),
                          getTile(utils.getTranslated(context, "rate"),
                              "assets/images/rateus_icon.png"),
                          getTile(utils.getTranslated(context, "share"),
                              "assets/images/share_app.png"),
                          getTile(utils.getTranslated(context, "logout"),
                              "assets/images/logout_icon.png"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * .22 - 50,
                left: MediaQuery.of(context).size.width / 2.5,
                child: GestureDetector(
                  onTap: () {
                    if(!_auth.currentUser!.isAnonymous){
                      openEditProfileBottomSheet();
                    }
                  },
                  child: Container(
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(profilePic),
                              radius: 35,
                            ),
                            backgroundColor: primaryColor,
                            radius: 40,
                          ),
                          _auth.currentUser!.isAnonymous
                              ? Container()
                              : Positioned.directional(
                              textDirection: Directionality.of(context),
                              bottom: 8,
                              end: 0,
                              child: Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    color: grey,
                                    borderRadius:
                                    BorderRadius.circular(50.0)),
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: primaryColor,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              utils.showCircularProgress(isLoading,secondarySelectedColor),
            ],
          ),
        ));
  }

  _imgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });

    uploadImageToFirebase(context);
    Navigator.pop(context);
  }

  void changeUserNameInFirebase() async {
    Navigator.of(context).pop();
    final form = _nameFieldKey.currentState!;
    form.save();
    if (form.validate()) {
      var ins = GetUserInfo();
      await ins.setUsername(name);
    }
  }

  Future uploadImageToFirebase(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    var fileName = _imageFile!.path.split('/').last;

    var ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('userProfiles')
        .child('/$fileName');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    firebase_storage.UploadTask uploadTask;
    uploadTask = ref.putFile(File(_imageFile!.path), metadata);

    await Future.value(uploadTask).then((value) async {
      var data = await value.ref.getDownloadURL();
      var ins = GetUserInfo();
      await ins.setProfilePic(data);

      utils.setSnackbar(
          context, utils.getTranslated(context, "ProfileUpdatedSuccessfully"));
      setState(() {
        isLoading = false;
      });
    }).onError((error, stackTrace) {
      if (mounted) {
        utils.setSnackbar(
            context, utils.getTranslated(context, "SomethingWentWrong"));
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  changeValue(bool val) async {
    SharedPreferences _sp = await SharedPreferences.getInstance();
    await _sp.setBool(appName + "SFX-ENABLED", val);
  }

  getTile(String title, String img) {
    return ListTile(
      leading: title != utils.getTranslated(context, 'changeLanguage')
          ?  title != utils.getTranslated(context, 'playMoreGames') ?
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(img),
        ],
      ) : Icon(
        Icons.games,
        color: primaryColor,
        size: 20,
      )
          : Icon(
        Icons.translate_outlined,
        color: primaryColor,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        try {
          music.play(click);

          if (title == utils.getTranslated(context, "history")) {
            await InternetAddress.lookup('google.com');
            Navigator.of(context).push(
              CupertinoPageRoute(
                  builder: (context) {
                    return GameHistory();
                  },
                  fullscreenDialog: true),
            );
          } else if (title == utils.getTranslated(context, "shop")) {
            await InternetAddress.lookup('google.com');
            Navigator.pushNamed(context, "/shop");
          } else if (title == utils.getTranslated(context, "skin")) {
            await InternetAddress.lookup('google.com');
            Navigator.of(context).pushNamed("/skin");
          }
        } on SocketException catch (_) {
          var dialog = Dialoge();
          dialog.error(context);
        }
        if (title == utils.getTranslated(context, "aboutUs")) {
          music.play(click);
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => PrivacyPolicy(
                    title: utils.getTranslated(context, "aboutUs"),
                  )));
        }else if (title == utils.getTranslated(context, "playMoreGames")) {
          music.play(click);
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => MoreGamesListing()));
        } else if (title == utils.getTranslated(context, "contactUs")) {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => PrivacyPolicy(
                    title: utils.getTranslated(context, "contactUs"),
                  )));
        } else if (title == utils.getTranslated(context, "termCond")) {
          music.play(click);
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => PrivacyPolicy(
                    title: utils.getTranslated(context, "termCond"),
                  )));
        } else if (title == utils.getTranslated(context, "privacy")) {
          music.play(click);
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => PrivacyPolicy(
                    title: utils.getTranslated(context, "privacy"),
                  )));
        } else if (title == utils.getTranslated(context, "howToPlayHeading")) {
          music.play(click);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => HowToPlay()));
        } else if (title == utils.getTranslated(context, "rate")) {
          _openStoreListing();
        } else if (title == utils.getTranslated(context, "share")) {
          var str =
              "$appName\n\n$appFind$androidLink$packageName\n\n iOS:\n$iosLink$iosPackage";

          Share.share(str);
        } else if (title == utils.getTranslated(context, "logout")) {
          showDialog(
              context: context,
              builder: (context) {
                var color = secondaryColor;

                return Alert(
                  title: Text(
                    utils.getTranslated(context, "logout"),
                    style: TextStyle(color: white),
                  ),
                  isMultipleAction: true,
                  defaultActionButtonName: utils.getTranslated(context, "ok"),
                  onTapActionButton: () {},
                  content: Text(
                    utils.getTranslated(context, "areYouSure"),
                    style: TextStyle(color: white),
                  ),
                  multipleAction: [
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(color)),
                        onPressed: () async {
                          var userID = FirebaseAuth.instance.currentUser!.uid;
                          if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                            Dialoge.removeChild("users", userID);
                          }

                          localValue.setSkinValue("user_skin", "");
                          localValue.setSkinValue("opponent_skin", "");
                          await utils.setUserLoggedIn("isLoggedIn", false);
                          bool value = await utils.getUserLoggedIn("isLoggedIn");
                          print("value is $value");
                          await FirebaseAuth.instance.signOut();

                          await GoogleSignIn().signOut();

                          music.play(click);

                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/authscreen', (Route<dynamic> route) => false);
                        },
                        child: Text(utils.getTranslated(context, "yes"),
                            style: TextStyle(color: white))),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(color)),
                        onPressed: () async {
                          music.play(click);

                          Navigator.pop(context);
                        },
                        child: Text(utils.getTranslated(context, "no"),
                            style: TextStyle(color: white)))
                  ],
                );
              });
        } else if (title == utils.getTranslated(context, 'changeLanguage')) {
          openChangeLanguageBottomSheet();
        }
        // }
      },
    );
  }

  Future<void> getSound() async {
    sound = await (utils.getSfxValue());
    setState(() {});
  }

  _getSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String getlanguage = prefs.getString(LAGUAGE_CODE) ?? "";

    selectedLanguage = langCode.indexOf(getlanguage == "" ? "en" : getlanguage);

    if (mounted) setState(() {});
  }

  void _changeLan(String language, BuildContext ctx) async {
    Locale _locale = await utils.setLocale(language);
    MyApp.setLocale(ctx, _locale);
  }

  void openChangeLanguageBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      bottomSheetHandle(),
                      bottomsheetLabel("changeLanguage"),
                      StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setModalState) {
                          return SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: getLngList(context, setModalState)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  void openEditProfileBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      bottomSheetHandle(),
                      bottomsheetLabel("editProfile"),
                      StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setModalState) {
                          return SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: _imgFromGallery,
                                    child: Container(
                                      child: Center(
                                        child: Stack(
                                          children: [
                                            CircleAvatar(
                                              child: CircleAvatar(
                                                backgroundImage:
                                                NetworkImage(profilePic),
                                                radius: 39,
                                              ),
                                              backgroundColor: primaryColor,
                                              radius: 40,
                                            ),
                                            Positioned.directional(
                                                textDirection:
                                                Directionality.of(context),
                                                bottom: 0,
                                                end: 0,
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets.all(2.0),
                                                  decoration: BoxDecoration(
                                                      color: grey,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          50.0)),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                    color: primaryColor,
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: TextFormField(
                                      key: _nameFieldKey,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textInputAction: TextInputAction.next,
                                      initialValue: username,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return utils.getTranslated(
                                              context, "usernameRequired");
                                        }
                                      },
                                      onSaved: (String? value) {
                                        name = value ?? username;
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle_outlined,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                        hintText: utils.getTranslated(
                                            context, "username"),
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                            color: primaryColor,
                                            fontWeight: FontWeight.normal),
                                        filled: true,
                                        fillColor: white,
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        prefixIconConstraints:
                                        const BoxConstraints(
                                          minWidth: 40,
                                          maxHeight: 20,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(7.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        bottom: 20.0, end: 20.0, start: 20.0),
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty.all(
                                                primaryColor)),
                                        onPressed: changeUserNameInFirebase,
                                        child: Text(
                                          utils.getTranslated(context, "save"),
                                          style: TextStyle(color: white),
                                        )),
                                  )
                                ]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  List<Widget> getLngList(BuildContext ctx, StateSetter setModalState) {
    return languageList
        .asMap()
        .map(
          (index, element) => MapEntry(
          index,
          InkWell(
            onTap: () {
              if (mounted) {
                setState(() {
                  selectedLanguage = index;
                  _changeLan(langCode[index], ctx);
                  _getLanguageList();
                });
                setModalState(() {

                });
              }

            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 25.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedLanguage == index
                                ? secondaryColor
                                : white,
                            border: Border.all(color: secondaryColor)),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: selectedLanguage == index
                              ? Icon(
                            Icons.check,
                            size: 17.0,
                            color: white,
                          )
                              : Icon(
                            Icons.check_box_outline_blank,
                            size: 15.0,
                            color: white,
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 15.0,
                          ),
                          child: Text(
                            languageList[index]!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: primaryColor),
                          ))
                    ],
                  ),
                ],
              ),
            ),
          )),
    )
        .values
        .toList();
  }

  Widget bottomSheetHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0), color: secondaryColor),
        height: 5,
        width: MediaQuery.of(context).size.width * 0.3,
      ),
    );
  }

  Widget bottomsheetLabel(String labelName) => Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 20),
      child: Text(
        utils.getTranslated(context, labelName),
        style: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.bold),
      ));

  void _getLanguageList() {
    languageList = [
      utils.getTranslated(context, 'ENGLISH_LAN'),
      utils.getTranslated(context, 'SPANISH_LAN'),
      utils.getTranslated(context, 'HINDI_LAN'),
      utils.getTranslated(context, 'ARABIC_LAN'),
      utils.getTranslated(context, 'RUSSIAN_LAN'),
      utils.getTranslated(context, 'JAPANISE_LAN'),
      utils.getTranslated(context, 'GERMAN_LAN')
    ];
  }
}
