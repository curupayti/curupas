import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:onboarding_flow/business/validator.dart';
import 'package:flutter/services.dart';
import 'package:onboarding_flow/models/user.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:onboarding_flow/ui/screens/widgets/alert_sms_dialog.dart';
import 'package:onboarding_flow/ui/screens/widgets/flat_button.dart';
import 'package:onboarding_flow/ui/screens/widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:location/location.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullname = new TextEditingController();
  final TextEditingController _number = new TextEditingController();
  final TextEditingController _birthday = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  CustomTextField _nameField;
  CustomTextField _phoneField;
  CustomTextField _birthdayField;
  CustomTextField _emailField;
  CustomTextField _passwordField;

  //https://medium.com/flutterpub/flutter-keyboard-actions-and-next-focus-field-3260dc4c694

  FocusNode _emailFocus = FocusNode();

  bool _blackVisible = false;
  VoidCallback onBackPress;

  GestureDetector _avatar;

  Image _avatarImage = Image.asset("assets/images/default.png");

  ClipOval _avatarClip;

  bool _loadingInProgress = false;

  double width, _left;

  //File vars
  String _imagePath;
  bool _imageSelected = false;

  OverlayEntry overlayEntry;
  FocusNode phoneNumberFocusNodeSignUp = new FocusNode();
  FocusNode passFocusNodeSignUp = new FocusNode();
  InputDoneSignUp inputDoneSignUp;

  CustomFlatButton _regiterButton;

  LocationData currentLocation;
  Location location = new Location();
  //GeoFirePoint point;
  //Geoflutterfire geo = Geoflutterfire();

  LocationData _locationData;

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _getLocaton();

    location.onLocationChanged().listen((LocationData currentLocation) {
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    });

    if (_globals.filePickerGlobal == null) {
      _globals.setFilePickerGlobal();
    }

    onBackPress = () {
      Navigator.of(context).pop();
    };

    _nameField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _fullname,
      hint: "Nombre completo",
      inputAction: TextInputAction.done,
      validator: Validator.validateName,
    );

    inputDoneSignUp = new InputDoneSignUp(this);

    _phoneField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _number,
      hint: "Telefono móvil",
      validator: Validator.validatePhone,
      inputAction: TextInputAction.next,
      inputType: TextInputType.number,
      focusNode: phoneNumberFocusNodeSignUp,
    );

    _birthdayField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _birthday,
      hint: "Fecha de nacimiento",
      validator: Validator.validateBirthday,
      inputType: TextInputType.datetime,
    );

    _emailField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _email,
      hint: "Dirección de E-mail",
      inputType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
      inputAction: TextInputAction.done,
      focusNode: _emailFocus,
    );

    _passwordField = CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Contraseña",
      validator: Validator.validatePassword,
      inputAction: TextInputAction.done,
      focusNode: passFocusNodeSignUp,
    );

    createRegisterButton(false);

    phoneNumberFocusNodeSignUp.addListener(() {
      bool hasFocus = phoneNumberFocusNodeSignUp.hasFocus;
      if (hasFocus) {
        showKeyboardOverlayButton(context);
      } else {
        removeOverlay();
      }
    });

    passFocusNodeSignUp.addListener(() {
      bool hasFocus = passFocusNodeSignUp.hasFocus;
      if (!hasFocus) {
        bool completed = true;
        if (!_imageSelected) {
          completed = false;
        } else if (_fullname.text.isEmpty) {
          completed = false;
        } else if (_number.text.isEmpty) {
          completed = false;
        } else if (_birthday.text.isEmpty) {
          completed = false;
        } else if (_email.text.isEmpty) {
          completed = false;
        } else if (_password.text.isEmpty) {
          completed = false;
        }
        if (completed) {
          enableButton();
        }
      }
    });

    setState(() {
      _fullname.text = "Jose Vigil";
      _number.text = "1169776624";
      _birthday.text = "30/09/1973";
      _email.text = "josemanuelvigil@gmail.com";
    });
  }

  void _getLocaton() async {
    try {
      _locationData = await location.getLocation();
      //var pos = await location.getLocation();
      //point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    } on Exception catch (error) {
      print(error.toString());
      currentLocation = null;
    }
  }

  void enableButton() {
    createRegisterButton(true);
    _rebuild();
  }

  void createRegisterButton(bool enabled) {
    Color color, borderColor, textColor;
    if (enabled) {
      color = Color.fromRGBO(59, 89, 152, 1.0);
      borderColor = Color.fromRGBO(59, 89, 152, 1.0);
      textColor = Colors.white;
    } else {
      color = Colors.black26;
      borderColor = Colors.black54;
      textColor = Colors.black26;
    }
    _regiterButton = CustomFlatButton(
      title: "Registrate",
      fontSize: 22,
      fontWeight: FontWeight.w700,
      textColor: textColor, //Colors.white,
      enabled: enabled,
      onPressed: () {
        _signUp(
            fullname: _fullname.text,
            phone: _number.text,
            birthday: _birthday.text,
            email: _email.text,
            password: _password.text,
            context: context);
      },
      splashColor: Colors.black12,
      borderColor: borderColor, //Color.fromRGBO(59, 89, 152, 1.0),
      borderWidth: 0,
      color: color, //Color.fromRGBO(59, 89, 152, 1.0),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: _showScreen(),
    );
  }

  Widget _showScreen() {
    if (_loadingInProgress) {
      return Stack(children: <Widget>[
        new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: new Text(
                  "Guardando datos de registracion",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
              new Container(
                width: 60,
                height: 60,
                child: new CircularProgressIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: new Text(
                  "Un momento por favor",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
            ],
          ),
        ),
      ]);
    } else {
      width = MediaQuery.of(context).size.width;
      double divided = width / 3;
      _left = divided - 10.0;
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 30.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Text(
                        "Crea una nueva cuenta",
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
                      padding: EdgeInsets.only(top: 10.0),
                      child: new Stack(fit: StackFit.loose, children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              width: 200.0,
                              height: 200.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30),
                              ),
                              margin:
                                  const EdgeInsets.only(top: 32.0, left: 16.0),
                              padding: const EdgeInsets.all(3.0),
                              child: ClipOval(
                                child: _avatarImage,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 180.0, left: _left),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new GestureDetector(
                                  onTap: () {
                                    _globals.filePickerGlobal
                                        .getImagePath()
                                        .then((result) {
                                      File _file = new File(result);
                                      if (_file != null) {
                                        _imageSelected = true;
                                        _imagePath = result;
                                        Image _newImage = new Image.file(_file);
                                        _avatarImage = _newImage;
                                        _rebuild();
                                      }
                                    });
                                  },
                                  child: new CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 30.0,
                                    child: new Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ]),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                      child: _nameField,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                      child: _phoneField,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                      child: InkWell(
                        onTap: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(1920, 1, 1),
                              maxTime: DateTime(2019, 6, 7), onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                            var formatter = new DateFormat('dd/MM/yyyy');
                            String formatted = formatter.format(date);
                            _birthday.text = formatted;
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType
                                  .es); // Call Function that has showDatePicker()
                        },
                        child: IgnorePointer(
                          child: _birthdayField,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                      child: _emailField,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                      child: _passwordField,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 40.0),
                      child: _regiterButton,
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
      );
    }
  }

  //For numeric keyboard "Cerrar" button
  showKeyboardOverlayButton(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: inputDoneSignUp);
    });

    overlayState.insert(overlayEntry);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    phoneNumberFocusNodeSignUp.dispose();
    super.dispose();
  }

  void _signUp(
      {String fullname,
      String phone,
      String birthday,
      String email,
      String password,
      BuildContext context}) async {
    if ( //Validator.validateName(fullname) &&
        Validator.validatePhone(phone) &&
            Validator.validateBirthday(birthday) &&
            Validator.validateEmail(email) &&
            Validator.validatePassword(password)) {
      setState(() {
        _loadingInProgress = true;
      });
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _changeBlackVisible();
        await Auth.signUp(email, password).then((uID) async {
          if (_imageSelected) {
            if (uID == _globals.error_email_already_in_use) {
              _globals.showErrorAlert(
                context: context,
                title: _globals.register_error_title,
                content: "Tu mail yo se encuentra registrado.",
                onPressed: () {
                  setState(() {
                    _email.clear();
                    FocusScope.of(context).requestFocus(_emailFocus);
                    _blackVisible = !_blackVisible;
                    _loadingInProgress = false;
                  });
                },
              );
            } else if (uID == _globals.error_unknown) {
              _globals.showErrorAlert(
                context: context,
                title: _globals.register_error_title,
                content: "Error desconocido, contacta al adinistrador.",
                onPressed: _changeBlackVisible,
              );
            } else {
              String loweName = fullname.toLowerCase();
              String toUnderscore = loweName.replaceAll(" ", "_");
              String toNonSpecial = removeDiacritics(toUnderscore);

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('userId', uID);
              prefs.setString('_imagePath', _imagePath);
              prefs.setString('toNonSpecial', toNonSpecial);

              int code = await _globals.generateRandom();

              Map<String, dynamic> data = new Map<String, dynamic>();
              data["locationData"] = _locationData;

              List<int> userType = new List<int>();
              userType.add(2);

              DocumentReference roleRef = await Auth.getRoleGroupReference();

              User user = new User(
                  userID: uID,
                  phone: phone,
                  email: email,
                  name: fullname,
                  birthday: birthday,
                  nonSpName: toNonSpecial,
                  roleRef: roleRef,
                  smsCode: code,
                  accepted: false,
                  locationData: _locationData);

              var message = _globals.getCodeMessgae(code);

              bool added = await Auth.addUser(user);
              if (added) {
                prefs.setBool('registered', true);
                _globals.sendUserSMSVerification(phone, message, uID, code);
                if (inputDoneSignUp != null) {
                  phoneNumberFocusNodeSignUp = null;
                  inputDoneSignUp = null;
                }
                setState(() {
                  _loadingInProgress = false;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) => new SMSDialog(userId: uID),
                );
              }
            }
          }
        });
      } catch (e) {
        print("Error in sign up: $e");
        String exception = Auth.getExceptionText(e);
        _globals.showErrorAlert(
          context: context,
          title: _globals.register_error_title,
          content: exception,
          onPressed: _changeBlackVisible,
        );
        setState(() {
          _loadingInProgress = false;
        });
      }
    }
  }

  Widget _buildSendSMSDialog(BuildContext context) {
    return new AlertDialog(
      title: Text('Confirmación de numero',
          style: TextStyle(
              color: Colors.blue, fontSize: ScreenUtil().setSp(40.0))),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAboutText(),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 15.0, left: 15.0),
          child: new FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/group");
            },
            textColor: Colors.white,
            child: Text(
              'SIGUIENTE',
              style: TextStyle(
                  color: Colors.blue, fontSize: ScreenUtil().setSp(40.0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutText() {
    return new RichText(
      text: new TextSpan(
        text:
            'Un mensaje SMS se ha sido enviado con un ccodigo que debes ingresar en la próxima pantalla.\n\n',
        style: TextStyle(
            color: Colors.black87, fontSize: ScreenUtil().setSp(30.0)),
        children: <TextSpan>[
          new TextSpan(
              text:
                  'Si no lo recibiste por favor ponete en contacto con el referente de tu camada.',
              style: TextStyle(
                  color: Colors.black87, fontSize: ScreenUtil().setSp(30.0))),
        ],
      ),
    );
  }

  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }
}

class InputDoneSignUp extends StatelessWidget {
  _SignUpScreenState parent;

  InputDoneSignUp(this.parent);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black, //Color(Const.doneButtonBg),
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
                    color: Colors.white, //Color(Const.colorPrimary),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0)),
          ),
        ),
      ),
    );
  }
}
