
  import 'dart:core';
  import 'dart:io';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:curupas/models/club.dart';
  import 'package:diacritic/diacritic.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:flutter/cupertino.dart';
  import "package:flutter/material.dart";
  import 'package:flutter/rendering.dart';
  import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:curupas/business/auth.dart';
  import 'package:curupas/business/validator.dart';
  import 'package:flutter/services.dart';
  import 'package:curupas/models/curupa_user.dart';
  import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
  import 'package:intl/intl.dart';
  import 'package:curupas/ui/widgets/alert_sms_dialog.dart';
  import 'package:curupas/ui/widgets/flat_button.dart';
  import 'package:curupas/ui/widgets/text_field.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:curupas/globals.dart' as _globals;
  import 'package:location/location.dart';

  class GuestScreen extends StatefulWidget {
    @override
    _GuestScreenState createState() => _GuestScreenState();
  }

  class _GuestScreenState extends State<GuestScreen> {

    final TextEditingController _number = new TextEditingController();
    final TextEditingController _fullname = new TextEditingController();

    CustomTextField _phoneField;
    CustomTextField _nameField;

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

    FocusNode nameFocus = new FocusNode();
    FocusNode phoneNumberFocus = new FocusNode();

    InputDoneSignUp inputDoneSignUp;

    CustomFlatButton _loginButton;

    LocationData currentLocation;
    Location location = new Location();
    //GeoFirePoint point;
    //Geoflutterfire geo = Geoflutterfire();

    LocationData _locationData;

    List<Club> _clubs = new List();
    List<DropdownMenuItem<String>> _clubMenuItems = new List();
    String _currentItem;
    Club _currentClub;

    Text _newClubText;
    bool _isNewGroupVisible = true;

    void _rebuild() {
      setState(() {});
    }

    @override
    void initState() {
      super.initState();

      //Informacion de cludes
      //https://urba.org.ar/informacion-de-clubes

      _getLocaton();

      // Subscribe
      KeyboardVisibility.onChange.listen((bool visible) {
        print('Keyboard visibility update. Is visible: ${visible}');
      });

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

      inputDoneSignUp = new InputDoneSignUp(this);

      _nameField = new CustomTextField(
        baseColor: Colors.grey,
        borderColor: Colors.grey[400],
        errorColor: Colors.red,
        controller: _fullname,
        hint: "Nombre completo",
        inputAction: TextInputAction.done,
        validator: Validator.validateName,
        focusNode: nameFocus,
        style: TextStyle(
          fontSize: 28,
        ),
      );

      _phoneField = new CustomTextField(
        baseColor: Colors.grey,
        borderColor: Colors.grey[400],
        errorColor: Colors.red,
        controller: _number,
        hint: "Telefono 10 dígitos",
        validator: Validator.validatePhone,
        inputAction: TextInputAction.next,
        inputType: TextInputType.number,
        focusNode: phoneNumberFocus,
        style: TextStyle(
          fontSize: 25,
        ),
      );

      createLoginButton(false);

      phoneNumberFocus.addListener(() {
        bool hasFocus = phoneNumberFocus.hasFocus;
        if (hasFocus) {
          showKeyboardOverlayButton(context);
        } else {
          removeOverlay();
          doComplete();
        }
      });

      nameFocus.addListener(() {
        bool hasFocus = nameFocus.hasFocus;
        if (!hasFocus) {
          doComplete();
        }
      });

      getClubsList().then((val) =>
          setState(() {
            //_number.text = "1169776624";
            _loadingInProgress = false;
            _clubMenuItems = val;
            print(_clubMenuItems.length);
            _currentItem = _clubMenuItems[0].value;
          })
      );

      onBackPress = () {
        Navigator.of(context).pop();
      };

    }

    void doComplete() {
      bool completed = true;
      if  (_fullname.text.isEmpty) {
        completed = false;
      }
      if  (_number.text.isEmpty) {
        completed = false;
      }
      if (completed) {
        enableButton();
      }
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
      createLoginButton(true);
      _rebuild();
    }

    void createLoginButton(bool enabled) {
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
      _loginButton = CustomFlatButton(
        title: "Ingresar",
        fontSize: 22,
        fontWeight: FontWeight.w700,
        textColor: textColor, //Colors.white,
        enabled: enabled,
        onPressed: () {
          setState(() {
            _loadingInProgress = true;
            _guestLogin(_locationData, _number.text);
          });
        },
        splashColor: Colors.black,
        borderColor: borderColor, //Color.fromRGBO(59, 89, 152, 1.0),
        borderWidth: 0,
        color: color, //Color.fromRGBO(59, 89, 152, 1.0),
      );
    }

    void _guestLogin(LocationData _locationData, String phone) async {

      try {

        var userId = await Auth.signInGuest();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', userId);
        prefs.setBool('guest', true);

        int code = await _globals.generateRandom();

        DocumentReference roleRef = await Auth.getRoleGroupReferenceByPath("roles/guest");

        CurupaUser user = new CurupaUser(
            name: _fullname.text,
            userID: userId,
            phone: phone,
            roleRef: roleRef,
            smsCode: code,
            accepted: true,
            locationData: _locationData);

        var message = _globals.getCodeMessgae(code);

        bool added = await Auth.addUser(user);

        if (added) {

          //prefs.setBool('registered', true);
          _globals.sendUserSMSVerification(phone, message, userId, code);

          if (inputDoneSignUp != null) {
            phoneNumberFocus = null;
            inputDoneSignUp = null;
          }
          setState(() {
            _loadingInProgress = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) =>
            new SMSDialog(userId: userId, phone: phone),
          );

        }

      } catch (e) {
        print('caught generic exception');
        print(e);
      }

    }

    Future<List<DropdownMenuItem<String>>> getClubsList() async {
      List<DropdownMenuItem<String>> items = new List();
      QuerySnapshot querySnapshot = await Auth.getClubSnapshot();
      for (var doc in querySnapshot.docs) {
        String name = doc.id;
        _clubs.add(new Club(name: name));
        items.add(new DropdownMenuItem(value: name, child: new Text(name)));
      }
      print(items.length);
      return items;
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
                          "Ingreso visitas",
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
                        padding: const EdgeInsets.only(
                            top: 30.0, left: 20.0, right: 20.0),
                        child: new Container(
                          child: new Center(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Text("Selecciona tu club",
                                      style: TextStyle(
                                          fontSize: 25.0, color: Colors.grey),
                                      textAlign: TextAlign.center),
                                  new Container(
                                    padding: new EdgeInsets.only(top: 20.0),
                                  ),
                                  new DropdownButton(
                                    value: _currentItem,
                                    items: _clubMenuItems,
                                    iconSize: 80.0,
                                    style: TextStyle(
                                        fontSize: 35.0,
                                        color: Colors.black,
                                        backgroundColor: Colors.white),
                                    onChanged: _changedClubItem,
                                  )
                                ],
                              )),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                        child: new Text("Ingresa datos de contacto",
                            style: TextStyle(
                                fontSize: 25.0, color: Colors.grey),
                            textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                        child: _nameField,
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                        child: _phoneField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25.0, horizontal: 40.0),
                        child: _loginButton,
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

    void _changedClubItem(String selected) {
      setState(() {
        _loadingInProgress = false;
        _currentItem = selected;
        if (selected != null) {
          _currentClub = _getGroupById(selected);
          String groupId = _currentClub.id;
          String name = _currentClub.name;
          print(name);
          print(groupId);
          _clubSelected(name);
        }
      });
    }

    void _clubSelected(String selected) {
      setState(() {
        _createNewTextClub(
            "Elegiste ${selected}, ingresa tu numero de telefono.");
        _isNewGroupVisible = false;
        //_enableButton();
      });
    }

    void _enableButton() {
      createLoginButton(true);
      _rebuild();
    }

    void _createNewTextClub(String text) {
      _newClubText = new Text(text,
          style: TextStyle(fontSize: 26.0, color: Colors.grey),
          textAlign: TextAlign.center);
    }

    Club _getGroupById(String documentId) {
      Club c;
      for (int i = 0; i < _clubs.length; i++) {
        if (_clubs[i].id == documentId) {
          c = _clubs[i];
        }
      }
      return c;
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
      phoneNumberFocus.dispose();
      super.dispose();
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

    _GuestScreenState parent;

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
