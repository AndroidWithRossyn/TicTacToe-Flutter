import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:TicTacToe/functions/dialoges.dart';
import 'package:TicTacToe/functions/gameHistory.dart';
import 'package:TicTacToe/models/userModle.dart';
import 'package:TicTacToe/screens/login_with_email.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as app;

class Auth {
  static Future anonymousSignin(BuildContext context) async {
    Dialoge.loading(context);

    Utils localValue = Utils();
    utils.setSfxValue();

    FirebaseAuth.instance.signInAnonymously().then((value) async {
      var username = "guest_" + value.user!.uid;
      var profilepic = guestProfilePic;

      /*await value.user!
          .updateProfile(displayName: username, photoURL: profilepic);*/

      await value.user!.updateDisplayName(username);
      await value.user!.updatePhotoURL(profilepic);
      var model = CreateUser(
          matchWon: 0,
          matchplayed: 0,
          profilePic: profilepic,
          username: username,
          userid: value.user!.uid,
          type: "GUEST");
      FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(value.user!.uid)
          .set(model.map())
          .then((a) async {
        FirebaseDatabase.instance
            .ref()
            .child("userSkins")
            .child(value.user!.uid)
            .push()
            .set({
          "itemid": "DORA Classic",
          "itemo": defaultOskin,
          "itemx": defaultXskin,
          "selectedStatus": "Active"
        });

        localValue.setSkinValue("user_skin", defaultXskin);
        localValue.setSkinValue("opponent_skin", defaultOskin);
        await utils.setUserLoggedIn("isLoggedIn", true);

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      });
    });
  }

  static Future sendForgotPasswordLink(userEmail) async {
    try {
      var auth = FirebaseAuth.instance;
      var user = await auth.sendPasswordResetEmail(email: userEmail);
      return user;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  static Future signin(context, fromAnonymous, platform,
      {coins,
      matchplayed,
      matchwon,
      guestUserID,
      score,
      email,
      password,
      username}) async {
    var credential, displayName, user;
    Utils localValue = Utils();
    if (platform == "Android" && email == "" && password == "") {
      GoogleSignIn signin = GoogleSignIn();
      user = await signin.signIn().then((value) async {
        await utils.setUserLoggedIn("isLoggedIn", true);

        Dialoge.loading(context);
        return value;
      });
      displayName = signin.currentUser!.displayName;

      var googleAuth = await user.authentication;
      credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) {
        Future.delayed(Duration(seconds: 2)).then((value) {
          localValue.setSkinValue("user_skin", defaultXskin);
          localValue.setSkinValue("opponent_skin", defaultOskin);
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        });
      });
    } else if (email != "" &&
        password != "" &&
        username != "" &&
        email != null &&
        password != null &&
        username != null) {
      //create user with email, password and username
      try {
        FirebaseAuth _auth = FirebaseAuth.instance;

        user = await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) async {
          await value.user!.sendEmailVerification().then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                utils.getTranslated(context, "verifyEmail"),
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor),
              ),
              backgroundColor: white,
              elevation: 1.0,
            ));
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => LoginWithEmail()));
          });

          //Dialoge.loading(context);
          return value;
        });
      } on FirebaseAuthException catch (e) {

        return e.message;
      }
      displayName = username;
    } else if (email != "" && password != "" && username == "") {
      //login user via email and pasword
      try {
        var _auth = FirebaseAuth.instance;

        user = await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) async {
          if (value.user!.emailVerified) {
            await utils.setUserLoggedIn("isLoggedIn", true);

            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                utils.getTranslated(context, "verifyEmail"),
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor),
              ),
              backgroundColor: white,
              elevation: 1.0,
            ));
          }
          //Dialoge.loading(context);
          return value;
        });

        return true;
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.message.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: primaryColor),
          ),
          backgroundColor: white,
          elevation: 1.0,
        ));
        return e.message;
      }
    } else if (platform == "IOS") {

      final _firebaseAuth = FirebaseAuth.instance;
      final app.AuthorizationResult result =
          await app.TheAppleSignIn.performRequests([
        user = app.AppleIdRequest(requestedScopes: [
          app.Scope.email,
          app.Scope.fullName,
        ])
      ]).then((value) async {
        localValue.setSkinValue("user_skin", defaultXskin);
        localValue.setSkinValue("opponent_skin", defaultOskin);
        await utils.setUserLoggedIn("isLoggedIn", true);
        return value;
      });

      switch (result.status) {
        case app.AuthorizationStatus.authorized:
          final appleIdCredential = result.credential;

          final oAuthProvider = OAuthProvider('apple.com');
          credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential!.identityToken!),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode!),
          );
          final authResult =
              await _firebaseAuth.signInWithCredential(credential);

          if (authResult.additionalUserInfo!.isNewUser) {
            final user = authResult.user!;

            print(appleIdCredential.fullName?.toMap());
            final String givenName =
                appleIdCredential.fullName?.givenName ?? "";
            final String familyName =
                appleIdCredential.fullName?.familyName ?? "";

            print("Given name : $givenName and Family name : $familyName");

            await user.updateDisplayName(
                (givenName.isEmpty && familyName.isEmpty)
                    ? "Your name"
                    : "$givenName $familyName");
            await user.reload();
            displayName = _firebaseAuth.currentUser!.displayName!;
          } else {
            displayName = authResult.user!.displayName;
          }
          /*      await firebaseUser!
              .updateDisplayName(appleIdCredential.fullName!.givenName);*/

          Future.delayed(Duration(seconds: 2)).then((value) {
            localValue.setSkinValue("user_skin", defaultXskin);
            localValue.setSkinValue("opponent_skin", defaultOskin);
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          });
          break;
        case app.AuthorizationStatus.error:
          break;

        case app.AuthorizationStatus.cancelled:
          break;
      }
    }

    FirebaseDatabase db = FirebaseDatabase.instance;
    CreateUser create;

    if (user != null) {
      if (fromAnonymous) {
        //user is signing as Guest
        create = CreateUser(
            username: displayName,
            matchWon: matchwon,
            matchplayed: matchplayed,
            coin: coins,
            profilePic:
                FirebaseAuth.instance.currentUser!.photoURL ?? guestProfilePic,
            userid: FirebaseAuth.instance.currentUser!.uid,
            score: score,
            type: "AUTHORIZED");

        if (create != null) {
          Dialoge.removeChild("users", guestUserID);
          Dialoge.removeChild("userSkins", guestUserID);
        }
      } else {
        //new user
        create = CreateUser(
            username: displayName,
            matchWon: 0,
            matchplayed: 0,
            profilePic:
                FirebaseAuth.instance.currentUser!.photoURL ?? guestProfilePic,
            userid: FirebaseAuth.instance.currentUser!.uid,
            type: "AUTHORIZED");
      }

      //check user is old or not
      var isAlreadyInDb = await db
          .ref()
          .child("users")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .once();

      //if user is new to our app then set default skins

      if (isAlreadyInDb.snapshot.value == null) {
        db
            .ref()
            .child("users")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .set(create.map());
        await db
            .ref()
            .child("userSkins")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .push()
            .set({
          "itemid": "DORA Classic",
          "itemo": defaultOskin,
          "itemx": defaultXskin,
          "selectedStatus": "Active"
        });
      }

      //Remove History of guest user, if user moving to Email login
      if (guestUserID != null) {
        DatabaseEvent historyOfGuest = await db
            .ref()
            .child("gameHistory")
            .child(guestUserID)
            .child("played")
            .once();
        if (historyOfGuest.snapshot.value != null) {
          Map.from(historyOfGuest.snapshot.value as Map)
            ..forEach((key, val) {
              History().update(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                  date: val["playedDate"],
                  gotcoin: val["gotCoin"],
                  oppornentId: val["oppornentId"],
                  status: val["playedStatus"],
                  type: val["type"]);
            });
        }
        Dialoge.removeChild("gameHistory", guestUserID);
      }

      //set users active skins value to sharedpreference
      Utils localValue = Utils();
      DatabaseReference _userSkinRef;
      _userSkinRef = FirebaseDatabase.instance.ref().child("userSkins");
      DatabaseEvent userSkins = await _userSkinRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .once();
      Map map =  userSkins.snapshot.value as Map;

      map.forEach((key, value) {
        if (value["selectedStatus"] == "Active") {
          localValue.setSkinValue("user_skin", value["itemx"].toString());
          localValue.setSkinValue("opponent_skin", value["itemo"].toString());
          return;
        }
      });

      // if (!fromAnonymous) {
      //   Navigator.of(context)
      //       .pushNamedAndRemoveUntil('/home', (route) => false);
      // }
    }
    return user;
  }
}
