import 'dart:io';

import 'package:TicTacToe/Helper/color.dart';
import 'package:TicTacToe/functions/authentication.dart';
import 'package:TicTacToe/screens/login_with_email.dart';
import 'package:TicTacToe/screens/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({Key? key}) : super(key: key);

  @override
  _SigninWithEmailState createState() => _SigninWithEmailState();
}

class _SigninWithEmailState extends State<SignInWithEmail> {
  String? password, comfirmpass, email, username;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isPwdHidden = true, isConfirmPwdHidden = true, isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: utils.gradBack(),
            child: Stack(
              children: [
                Column(
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
                                getUsernameField(),
                                getPasswordField(),
                                getConfirmPasswordField(),
                                getSignUpButton(),
                                getLoginLabel(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
          ),
          utils.showCircularProgress(isLoading, secondarySelectedColor),
        ],
      ),
    );
  }

  Widget getSignInDora() {
    return Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Image.asset("assets/images/signin_Dora.png"));
  }

  Widget getEmailField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 20.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,

        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.normal,
        ),

        textInputAction: TextInputAction.next,
        // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => utils.validateEmail(
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
          hintStyle: Theme.of(context)
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

  Widget getUsernameField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 20.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,

        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.normal,
        ),

        textInputAction: TextInputAction.next,
        // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) {
          if (val!.isEmpty) {
            return utils.getTranslated(context, "usernameRequired");
          }
        },
        onSaved: (String? value) {
          username = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.person_outlined,
            color: primaryColor,
            size: 20,
          ),
          hintText: utils.getTranslated(context, "username"),
          hintStyle: Theme.of(context)
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
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 20.0,
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
        // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => utils.validatePass(
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
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxHeight: 35,
          ),
          hintText: utils.getTranslated(context, "password"),
          hintStyle: Theme.of(context)
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

  Widget getConfirmPasswordField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 20.0,
      ),
      child: TextFormField(
        obscureText: isConfirmPwdHidden,
        obscuringCharacter: "*",
        keyboardType: TextInputType.text,
        //controller: mobileController,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.normal,
        ),
        //focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value!.isEmpty) {
            return utils.getTranslated(context, "confirmPasswordRequired");
          }
          if (value != password) {
            return "${utils.getTranslated(context, "passwordDoesntMatch")}";
          } else {
            return null;
          }
        },
        onSaved: (String? value) {
          comfirmpass = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: primaryColor,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: isConfirmPwdHidden
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
                isConfirmPwdHidden = !isConfirmPwdHidden;
              });
            },
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxHeight: 35,
          ),
          hintText: utils.getTranslated(context, "confirmPassword"),
          hintStyle: Theme.of(context)
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

  Widget getSignUpButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          end: 30.0, top: 20.0, start: 25.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
                child: Text(
              utils.getTranslated(context, "signUp"),
              style: TextStyle(color: primaryColor, fontSize: 20),
              overflow: TextOverflow.ellipsis,
            )),
          ),
          onTap: (){
            setState(() {
              isLoading = true;
            });
            validateAndSubmit();
          } ,
        ),
      ),
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      var result = await Auth.signin(context, false, "android",
          email: email!.trim(), password: password, username: username!.trim());
      if (mounted) {
        setSnackbar(result.toString());
      }
    }
    if(mounted){
      setState(() {
        isLoading = false;
      });
    }
  }

  setSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: primaryColor),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
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
      child: Text(utils.getTranslated(context, "signUp"),
          style: TextStyle(color: lightWhite, fontSize: 20)),
    );
  }

  Widget getLoginLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0,bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(utils.getTranslated(context, "HaveAnAccount"), style: TextStyle(color: lightWhite)),
          InkWell(
            child:  Text(
              " ${utils.getTranslated(context, "signIn")}",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => LoginWithEmail()));
            },
          ),
        ],
      ),
    );
  }
}
