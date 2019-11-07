import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import "package:onboarding_flow/ui/widgets/custom_text_field.dart";
import 'package:onboarding_flow/business/auth.dart';
import 'package:onboarding_flow/business/validator.dart';
import 'package:flutter/services.dart';
import 'package:onboarding_flow/ui/widgets/custom_flat_button.dart';
import 'package:onboarding_flow/ui/widgets/custom_alert_dialog.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:onboarding_flow/models/user.dart';

class SignInScreen extends StatefulWidget {
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = new TextEditingController();
  FocusNode emailFocusNodeSignUp = new FocusNode();
  final TextEditingController _password = new TextEditingController();

  CustomTextField _emailField;
  CustomTextField _passwordField;
  //CustomTextField _numberField;
  bool _blackVisible = false;
  VoidCallback onBackPress;

  CustomFlatButton _loginButton;

  FocusNode passwordFocusNodeSignUp = new FocusNode();

  // TODO To be included a numeric input for number
  //OverlayEntry overlayEntry;
  //FocusNode phoneNumberFocusNodeSignIn = new FocusNode();
  //FocusNode numericFocusNodeSignIn = new FocusNode();
  //InputDoneSignIn inputDoneSignIn;

  @override
  void initState() {
    super.initState();

    /*_numberField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _number,
      hint: "Telefono móvil",
      validator: Validator.validatePhone,
      inputAction: TextInputAction.next,
      inputType: TextInputType.number,
      focusNode: phoneNumberFocusNodeSignIn,
    );*/

    //inputDoneSignIn = new InputDoneSignIn(this);

    /*phoneNumberFocusNodeSignIn.addListener(() {
      bool hasFocus = phoneNumberFocusNodeSignIn.hasFocus;
      if (hasFocus) {
        showKeyboardOverlayButton(context);
      } else {
        removeOverlay();
      }
    });*/

    onBackPress = () {
      Navigator.of(context).pop();
    };

    _emailField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _email,
      hint: "Dirección de E-mail",
      inputType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
      focusNode: emailFocusNodeSignUp,
    );
    _passwordField = CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Contraseña",
      validator: Validator.validatePassword,
      focusNode: passwordFocusNodeSignUp,
    );

    passwordFocusNodeSignUp.addListener(() {
      bool hasFocus = passwordFocusNodeSignUp.hasFocus;
      if (!hasFocus) {
        int length = _email.text.length;
        print(length);
        if (length > 0) {
          setState(() {
            _createLoginButton(true, Colors.white);
          });
        }
      }
    });

    _createLoginButton(false, Colors.black54);
  }

  void _createLoginButton(bool enabled, Color textColor) {
    _loginButton = CustomFlatButton(
      title: "Ingresa",
      fontSize: 22,
      fontWeight: FontWeight.w700,
      textColor: textColor, //Colors.white,
      onPressed: () {
        _emailLogin(
            email: _email.text, password: _password.text, context: context);
      },
      splashColor: Colors.black12,
      borderColor: Color.fromRGBO(212, 20, 15, 1.0),
      borderWidth: 0,
      color: Color.fromRGBO(212, 20, 15, 1.0),
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 70.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Text(
                        "Ingresa",
                        softWrap: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromRGBO(212, 20, 15, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "OpenSans",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.0, bottom: 10.0, left: 15.0, right: 15.0),
                      child: _emailField,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 20.0, left: 15.0, right: 15.0),
                      child: _passwordField,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 40.0),
                      child: _loginButton,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Con usuario y contraseña o",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OpenSans",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 40.0),
                      child: CustomFlatButton(
                        enabled: true,
                        title: "Facebook",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          _facebookLogin(context: context);
                        },
                        splashColor: Colors.black12,
                        borderColor: Color.fromRGBO(59, 89, 152, 1.0),
                        borderWidth: 0,
                        color: Color.fromRGBO(59, 89, 152, 1.0),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: onBackPress,
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: !_blackVisible,
              child: GestureDetector(
                onTap: () {},
                child: AnimatedOpacity(
                  opacity: _blackVisible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeBlackVisible() {
    setState(() {
      _email.clear();
      _password.clear();
      _blackVisible = !_blackVisible;
      FocusScope.of(context).requestFocus(emailFocusNodeSignUp);
    });
  }

  void _emailLogin(
      {String email, String password, BuildContext context}) async {
    if (Validator.validateEmail(email) &&
        Validator.validatePassword(password)) {
      //try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _changeBlackVisible();
      await Auth.signIn(email, password).then((ResutlLogin resutl) {
        if (resutl.error) {
          print("Error in email sign in: $resutl.result");
          _globals.showErrorAlert(
            context: context,
            title: "Error de autentificación",
            content: resutl.result,
            onPressed: _changeBlackVisible,
          );
        } else {
          String uid = resutl.result;
          Auth.setUserFrefs(uid);
          //Navigator.of(context).pop();
          Navigator.of(context).pushNamed("/main");
        }
      });
      /*} catch (e) {
        print("Error in email sign in: $e");
        String exception = Auth.getExceptionText(e);
        _globals.showErrorAlert(
          context: context,
          title: "Login failed",
          content: exception,
          onPressed: _changeBlackVisible,
        );
      }*/
    }
  }

  void _facebookLogin({BuildContext context}) async {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _changeBlackVisible();
      FacebookLogin facebookLogin = new FacebookLogin();
      FacebookLoginResult result = await facebookLogin
          .logInWithReadPermissions(['email', 'public_profile']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          Auth.signInWithFacebok(result.accessToken.token).then((uid) {
            Auth.getCurrentFirebaseUser().then((firebaseUser) {
              /*User user = new User(
                name: firebaseUser.displayName,
                userID: firebaseUser.uid,
                email: firebaseUser.email ?? '',
                profilePictureURL: firebaseUser.photoUrl ?? '',
              );
              Auth.addUser(user);*/
              Navigator.of(context).pop();
            });
          });
          break;
        case FacebookLoginStatus.cancelledByUser:
        case FacebookLoginStatus.error:
          _globals.showErrorAlert(
            context: context,
            title: _globals.signin_error_title,
            content:
                "Error en la autenfificación con el mail de Facebook", //result.errorMessage,
            onPressed: _changeBlackVisible,
          );
      }
    } catch (e) {
      print("Error in facebook sign in: $e");
      String exception = Auth.getExceptionText(e);
      _globals.showErrorAlert(
        context: context,
        title: _globals.signin_error_title,
        content: exception,
        onPressed: _changeBlackVisible,
      );
    }
  }

  /*showKeyboardOverlayButton(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: inputDoneSignIn);
    });

    overlayState.insert(overlayEntry);
  }*/

  /*removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }*/
}

/*class InputDoneSignIn extends StatelessWidget {
  _SignInScreenState parent;

  InputDoneSignIn(this.parent);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey, //Color(Const.doneButtonBg),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: CupertinoButton(
            padding: EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
            onPressed: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              //this.parent.setState(() {});
            },
            child: Text("Cerrar",
                style: TextStyle(
                    color: Colors.blue, //Color(Const.colorPrimary),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0)),
          ),
        ),
      ),
    );
  }
}*/
