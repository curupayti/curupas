import 'dart:async';
import 'dart:core';
import 'dart:io';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:onboarding_flow/business/auth.dart';
import "package:onboarding_flow/ui/widgets/custom_text_field.dart";
import 'package:onboarding_flow/business/validator.dart';
import 'package:flutter/services.dart';
import 'package:onboarding_flow/models/user.dart';
import 'package:onboarding_flow/ui/widgets/custom_flat_button.dart';
import 'package:onboarding_flow/ui/widgets/custom_alert_dialog.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onboarding_flow/globals.dart' as _globals;

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
  bool _blackVisible = false;
  VoidCallback onBackPress;

  GestureDetector _avatar;

  Image _avatarImage = Image.asset("assets/images/default.png");

  ClipOval _avatarClip;

  bool _loadingInProgress = false;

  double width, _left;

  //File vars
  String _imagePath;
  bool _imageSelected;

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };

    _nameField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _fullname,
      hint: "Nombre completo",
      validator: Validator.validateName,
    );

    _phoneField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _number,
      hint: "Telefono móvil",
      validator: Validator.validateNumber,
      inputType: TextInputType.number,
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
    );
    _passwordField = CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Contraseña",
      validator: Validator.validatePassword,
    );
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
                                        .getImagePath(false)
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
                      child: CustomFlatButton(
                        title: "Registrate",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          _signUp(
                              fullname: _fullname.text,
                              number: _number.text,
                              birthday: _birthday.text,
                              email: _email.text,
                              password: _password.text,
                              context: context);
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
      );
    }
  }

  void _signUp(
      {String fullname,
      String number,
      String birthday,
      String email,
      String password,
      BuildContext context}) async {
    if (Validator.validateName(fullname) &&
        Validator.validateEmail(email) &&
        Validator.validateNumber(number) &&
        Validator.validateBirthday(birthday) &&
        Validator.validatePassword(password) &&
        _imageSelected) {
      setState(() {
        _loadingInProgress = true;
      });
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _changeBlackVisible();

        await Auth.signUp(email, password).then((uID) async {
          if (_imageSelected) {
            //-
            //Uploading file
            /*String extension = p.extension(_imagePath);
            String fileName =
                Random().nextInt(1000000).toString() + '$extension';
            final StorageReference storageRef =
                FirebaseStorage.instance.ref().child(fileName);
            final StorageUploadTask uploadTask =
                storageRef.putFile(File(_imagePath));
            final StreamSubscription<StorageTaskEvent> streamSubscription =
                uploadTask.events.listen((event) {
              print('EVENT ${event.type}');
            });
            final StorageTaskSnapshot downloadUrl =
                (await uploadTask.onComplete);
            final String url = (await downloadUrl.ref.getDownloadURL());
            streamSubscription.cancel();*/
            _globals.filePickerGlobal.uploadFile(_imagePath).then((url) async {
              User user = new User(
                  userID: uID,
                  email: email,
                  name: fullname,
                  birthday: birthday,
                  profilePictureURL: url);
              bool added = await Auth.addUser(user);
              if (added) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('registered', true);
                prefs.setString('userId', uID);
                setState(() {
                  _loadingInProgress = false;
                });
                _globals.user = user;
                Navigator.of(context).pushNamed("/group");
              }
            });
          }
        });
      } catch (e) {
        print("Error in sign up: $e");
        String exception = Auth.getExceptionText(e);
        _showErrorAlert(
          title: "Signup failed",
          content: exception,
          onPressed: _changeBlackVisible,
        );
        setState(() {
          _loadingInProgress = false;
        });
      }
    }
  }

  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

  void _showErrorAlert({String title, String content, VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    );
  }
}
