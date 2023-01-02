import 'dart:io';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/functions/authentication.dart';
import 'package:TicTacToe/screens/signup_with_email.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginWithEmail extends StatefulWidget {
  const LoginWithEmail({Key? key}) : super(key: key);

  @override
  _LoginWithEmailState createState() => _LoginWithEmailState();
}

class _LoginWithEmailState extends State<LoginWithEmail> {
  String? password, comfirmpass, email;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final _emailFieldKey = GlobalKey<FormFieldState>();
  bool isPwdHidden = true,
      isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              decoration: utils.gradBack(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  getSignInDora(),
                  SizedBox(
                    height: 30.0,
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              getHeadingLabel(),
                              getEmailField(),
                              getPasswordField(),
                              getForgotPwdLabel(),

                              getSignInButton(),
                              getORLabel(),
                              getLoginOptions(),
                              getRegisterLabel(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            utils.showCircularProgress(isLoading, secondarySelectedColor),
            Platform.isIOS ?
            Positioned.directional(textDirection: Directionality.of(context),
                start: 5.0,top: 10.0,
                child: Container(
                  height: 35,width: 35,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10)),
                  child: FittedBox(
                    child: IconButton(
                      onPressed: (){

                        Navigator.pop(context);},
                      icon: Icon(Icons.arrow_back_ios_outlined,size: 30),

                    ),
                  ),
                )) :Container()
          ],
        ),
      ),
    );
  }

  Widget getSignInDora() {
    return Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.35,
        child: Image.asset("assets/images/signin_Dora.png"));
  }

  Widget getForgotPwdLabel() {
    return Padding(
      padding: const EdgeInsets.only(right: 30.0, top: 10.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          child: Text(utils.getTranslated(context, "forgotPassword"),
              style: TextStyle(color: lightWhite)),
          onTap: () async {
            final emailField = _emailFieldKey.currentState!;
            emailField.save();
            if (emailField.validate()) {
              await Auth.sendForgotPasswordLink(email!.trim()).then((value) {
                if (value == null) {
                  utils.setSnackbar(context,
                      utils.getTranslated(context, "resetPasswordEmailSent"));
                  return;
                }
                utils.setSnackbar(context, value.toString());
              });
              return;
            }
            utils.setSnackbar(
                context, utils.getTranslated(context, "enterEmail"));
          },
        ),
      ),
    );
  }

  Widget getEmailField() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.85,
      padding: const EdgeInsets.only(
        top: 20.0,
      ),
      child: TextFormField(
        key: _emailFieldKey,
        keyboardType: TextInputType.text,

        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.normal,
        ),

        textInputAction: TextInputAction.next,
        // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) =>
            utils.validateEmail(
                val!,
                utils.getTranslated(context, "emailRequired"),
                utils.getTranslated(context, "enterValidEmail")),
        onSaved: (String? value) {
          email = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email_outlined,
            color: primaryColor,
            size: 20,
          ),
          hintText: utils.getTranslated(context, "email"),
          hintStyle: Theme
              .of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: primaryColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  Widget getPasswordField() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.85,
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: TextFormField(
        obscureText: isPwdHidden,
        obscuringCharacter: "*",
        keyboardType: TextInputType.text,
        //controller: mobileController,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.normal,
        ),
        //focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        validator: (val) =>
            utils.validatePass(
                val!,
                utils.getTranslated(context, "passwordRequired"),
                utils.getTranslated(context, "passwordShouldHaveSixChar")),
        onSaved: (String? value) {
          password = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: primaryColor,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: isPwdHidden
                ? const Icon(
              Icons.visibility,
              size: 20.0,
            )
                : const Icon(
              Icons.visibility_off,
              size: 20.0,
            ),
            onPressed: () {
              setState(() {
                isPwdHidden = !isPwdHidden;
              });
            },
          ),
          hintText: utils.getTranslated(context, "password"),
          hintStyle: Theme
              .of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: primaryColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxHeight: 35,
          ),
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  Widget getLoginOptions() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      width: MediaQuery
          .of(context)
          .size
          .width * 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Platform.isIOS
              ? Row(
            children: [
              InkWell(
                onTap: () async {
                  Auth.signin(context, false, "IOS");
                },
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.13,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.06,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Image.asset('assets/images/apple_icon.png'),
                ),
              ),
              const SizedBox(
                width: 10.0,
              )
            ],
          )
              : Container(),
          InkWell(
            onTap: () async {
              await Auth.signin(context, false, "Android",
                  email: "", password: "");
            },
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.13,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.06,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Image.asset('assets/images/google_logo.png'),
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          InkWell(
            onTap: () async {
              await Auth.anonymousSignin(context);
            },
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.13,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.06,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Image.asset('assets/images/play_guest.png'),
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
        /*  Expanded(
            child: InkWell(
                child: Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.06,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                      child: Text(
                        utils.getTranslated(context, "signIn")!,
                        style: TextStyle(color: primaryColor, fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
                onTap: () {
                  setState(() {
                    isLoading = true;
                  });
                  validateAndSubmit();
                }),
          ),*/
        ],
      ),
    );
  }

  Widget getRegisterLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(utils.getTranslated(context, "newAccount"),
              style: TextStyle(color: lightWhite)),
          InkWell(
            child: Text(
              utils.getTranslated(context, "register"),
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => SignInWithEmail()));
            },
          ),
        ],
      ),
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      await Auth.signin(context, false, "android",
          email: email, password: password, username: "");
    }
    setState(() {
      isLoading = false;
    });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Widget getHeadingLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(utils.getTranslated(context, "signIn"),
          style: TextStyle(color: lightWhite, fontSize: 20)),
    );
  }

  Widget getORLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(utils.getTranslated(context, "or"),
          style: TextStyle(color: lightWhite)),
    );
  }

  getSignInButton() {
    return InkWell(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(top: 10.0),
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.60,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.06,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
                child: Text(
                  utils.getTranslated(context, "signIn"),
                  style: TextStyle(color: primaryColor, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                )),
          ),
        ),
        onTap: () {
          setState(() {
            isLoading = true;
          });
          validateAndSubmit();
        });
  }
}
