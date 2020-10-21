import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:curupas/business/auth.dart';
import 'package:curupas/business/validator.dart';
import 'package:curupas/models/group.dart';
import 'package:curupas/models/curupa_user.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/ui/widgets/flat_button.dart';
import 'package:curupas/ui/widgets/text_field.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpGroupScreen extends StatefulWidget {
  @override
  _SignUpGroupScreenState createState() => _SignUpGroupScreenState();
}

class _SignUpGroupScreenState extends State<SignUpGroupScreen> {

  List<DropdownMenuItem<String>> _groupMenuItems = new List();
  List<Group> _groups = new List();
  Group _currentGroup;
  String _currentItem;

  final TextEditingController _newGroup = new TextEditingController();
  CustomTextField _newGroupField;

  VoidCallback onBackPress;

  bool _loadingInProgress;

  OverlayEntry overlayEntry;
  FocusNode phoneNumberFocusNodeGroup = new FocusNode();
  CustomFlatButton _saveGroupButton;

  Text _newGroupText;
  bool _isNewGroupVisible = true;
  SharedPreferences prefs;

  String curupasUrl = 'https://curupas.com.ar/';

  TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontSize: 25.0,
  );

  TapGestureRecognizer _flutterTapRecognizer;

  final FirebaseMessaging _fcm = FirebaseMessaging();

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _loadingInProgress = true;

    _flutterTapRecognizer = new TapGestureRecognizer()
      ..onTap = () => _openUrl(curupasUrl);

    setButtonEnabled(false);

    phoneNumberFocusNodeGroup.addListener(() {
      bool hasFocus = phoneNumberFocusNodeGroup.hasFocus;
      if (hasFocus)
        showOverlayGroup(context);
      else
        removeOverlay();
    });

    _createNewTextGroup("Si tu camada no esta en el menu crea una nueva");
    _setButtonEnabled(false);

    _newGroupField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _newGroup,
      maxLength: 4,
      style: new TextStyle(
        fontSize: 25.0,
        height: 1.5,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      hint: "Ingresa tu camada",
      inputType: TextInputType.number,
      validator: Validator.validateShortNumber,
      focusNode: phoneNumberFocusNodeGroup,
    );

    getGroupsList().then((val) =>
      setState(() {
        _loadingInProgress = false;
        _groupMenuItems = val;
        print(_groupMenuItems.length);
        _currentItem = _groupMenuItems[0].value;
      }));
      onBackPress = () {
        Navigator.of(context).pop();
      };
  }

  void _enableButton() {
    setButtonEnabled(true);
    _rebuild();
  }

  void setButtonEnabled(bool enabled) {
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
    _saveGroupButton = CustomFlatButton(
      title: "Guardar Camada",
      enabled: enabled,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      textColor: textColor,
      onPressed: () {
        setState(() {
          _loadingInProgress = true;
          _saveGroup(context);
        });
      },
      splashColor: Colors.black12,
      borderColor: borderColor,
      borderWidth: 0,
      color: color, //
    );
  }

  Future<List<DropdownMenuItem<String>>> getGroupsList() async {
    List<DropdownMenuItem<String>> items = new List();
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("years").getDocuments();
    items.add(new DropdownMenuItem(value: null, child: new Text("----")));
    for (var doc in querySnapshot.documents) {
      String year = doc['year'];
      String documentID = doc.documentID;
      _groups.add(new Group(
          year: year, documentID: documentID, yearRef: doc.reference));
      items.add(new DropdownMenuItem(value: documentID, child: new Text(year)));
    }
    print(items.length);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(30.0),
                      bottom: ScreenUtil().setWidth(50.0),
                      left: ScreenUtil().setWidth(30.0),
                      right: ScreenUtil().setWidth(30.0)),
                  child: new Image.asset("assets/images/pelota_small.png",
                      height: ScreenUtil().setHeight(200.0),
                      fit: BoxFit.fitHeight),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(50.0)),
                child: new Text(
                  "Guardando datos",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: ScreenUtil().setSp(50.0),
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
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(50.0)),
                child: new Text(
                  "Un momento por favor",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: ScreenUtil().setSp(35.0),
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
      print(_currentItem);
      print(_groupMenuItems.length);
      return new Center(
        child: Stack(
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
                        "Datos de camada",
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
                            new Text("Selecciona tu camada",
                                style: TextStyle(
                                    fontSize: 25.0, color: Colors.grey),
                                textAlign: TextAlign.center),
                            new Container(
                              padding: new EdgeInsets.only(top: 20.0),
                            ),
                            new DropdownButton(
                              value: _currentItem,
                              items: _groupMenuItems,
                              iconSize: 80.0,
                              style: TextStyle(
                                  fontSize: 35.0,
                                  color: Colors.black,
                                  backgroundColor: Colors.white),
                              onChanged: _changedGroupItem,
                            )
                          ],
                        )),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 50.0, right: 50.0),
                      child: _newGroupText,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 50.0, right: 50.0),
                      child: Visibility(
                        visible: _isNewGroupVisible,
                        child: _newGroupField,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 30.0, left: 30.0, right: 30.0),
                      child: _saveGroupButton,
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
          ],
        ),
      );
    }
  }

  void _createNewTextGroup(String text) {
    _newGroupText = new Text(text,
        style: TextStyle(fontSize: 26.0, color: Colors.grey),
        textAlign: TextAlign.center);
  }

  void _groupSelected(String selected) {
    setState(() {
      _createNewTextGroup(
          "Elegiste la camada ${selected}, pulsa el boton de guardar");
      _isNewGroupVisible = false;
      _enableButton();
    });
  }

  void _setButtonEnabled(bool enabled) {
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
    _saveGroupButton = CustomFlatButton(
      title: "Guardar Camada",
      enabled: enabled,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      textColor: textColor,
      onPressed: () {
        _saveGroup(context);
      },
      splashColor: Colors.black12,
      borderColor: borderColor,
      borderWidth: 0,
      color: color,
    );
  }

  void _changedGroupItem(String selected) {
    setState(() {
      _loadingInProgress = false;
      _currentItem = selected;
      if (selected != null) {
        _currentGroup = _getGroupById(selected);
        String groupId = _currentGroup.documentID;
        String year = _currentGroup.year;
        print(year);
        print(groupId);
        _groupSelected(year);
      }
    });
  }

  Group _getGroupById(String documentId) {
    Group g;
    for (int i = 0; i < _groups.length; i++) {
      if (_groups[i].documentID == documentId) {
        g = _groups[i];
      }
    }
    return g;
  }

  void _createNewYear() async {
    String year = _newGroup.text;
    Auth.checkYearExist(year).then((result) {
      if (result) {
        _globals.showErrorAlert(
          context: context,
          title: "La camada ya existe",
          content:
              "La camada que intentas agregar ya existe, seleccionala en el menu.",
          onPressed: _closeDialog,
        );
        setState(() {
          _newGroup.clear();
        });
      } else {
        Auth.addYear(year).then((yearRef) async {
          DocumentSnapshot docsnapshot = await yearRef.get();
          if (docsnapshot.exists) {
            String year = docsnapshot['year'];
            String documentID = docsnapshot.documentID;
            setState(() {
              _loadingInProgress = true;
            });
            _groups = new List();
            getGroupsList().then((val) {
              _newGroup.clear();
              _groupMenuItems = val;
              _changedGroupItem(documentID);
              _groupSelected(year);
            });
          }
        });
      }
    });
  }

  void _saveGroup(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    String groupId = _currentGroup.documentID;
    String year = _currentGroup.year;

    DocumentReference yearRef =
        Firestore.instance.collection('years').document(groupId);

    int nowTime = new DateTime.now().millisecondsSinceEpoch;

    //Upload image
    String toNonSpecial = prefs.getString('toNonSpecial');
    String _imagePath = prefs.getString('_imagePath');
    String filePath = "${year}/users/${toNonSpecial}-${nowTime}";
    String thumbImageName = "${year}/thumb_${toNonSpecial}";

    String _extension = p.extension(_imagePath);
    print(_extension);
    String thumbImageNameExtension = thumbImageName + '$_extension';
    prefs.setString('thumbImageNameExtension', thumbImageNameExtension);

    Map<String, dynamic> data = <String, dynamic>{
      'year': _currentGroup.year,
      'yearRef': yearRef
    };

    Auth.updateUser(userId, data).then((user) async {
      if (user != null) {
        _fcm.subscribeToTopic('users');
        _fcm.subscribeToTopic(year);

        Map<String, String> meta = new Map<String, String>();
        meta["thumbnail"] = "true";
        meta["type"] = "2";
        meta["userId"] = "${userId}";
        meta["year"] = "${year}";

        StorageMetadata metadata = new StorageMetadata(
          customMetadata: meta,
        );

        _globals.filePickerGlobal
            .uploadFile(_imagePath, filePath, metadata)
            .then((url) {
          _globals.user = user;
          prefs.setBool('group', true);
          prefs.setString('year', year);
          _globals.user.yearRef = yearRef;
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildAboutDialog(context),
          );
        });
      }
    });
  }

  void _openUrl(String url) async {
    // Close the about dialog.
    //Navigator.pop(context);

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildAboutDialog(BuildContext context) {
    return new AlertDialog(
      title: Text('Registración exitosa',
          style: TextStyle(
              color: Colors.blue, fontSize: ScreenUtil().setSp(40.0))),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAboutText(),
          SizedBox(
            height: 16.0,
          ),
          _buildLogoAttribution(),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 15.0, left: 15.0),
          child: new FlatButton(
            onPressed: () {
              exit(0);
            },
            textColor: Colors.white,
            child: Text(
              'CERRAR APLICACIÓN',
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
            'Resta que un referente de tu camada apruebe tu ingreso. Te va a llegar una notificación cuando lo haga.\n\n',
        style: TextStyle(
            color: Colors.black87, fontSize: ScreenUtil().setSp(30.0)),
        children: <TextSpan>[
          new TextSpan(
              text:
                  'Mientras tanto, podes ver mas información del proyecto en ',
              style: TextStyle(
                  color: Colors.black87, fontSize: ScreenUtil().setSp(30.0))),
          new TextSpan(
            text: 'Curupas',
            recognizer: _flutterTapRecognizer,
            style: linkStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAttribution() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: new Image.asset(
              "assets/images/escudo.png",
              width: 50.0,
            ),
          ),
          const Expanded(
            child: const Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: const Text(
                'El regreso virtual es crecimiento',
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _closeDialog() {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
    //Navigator.of(context).pushNamed("/main");
  }

  void makeRoutePage({BuildContext context, Widget pageRef}) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => pageRef),
        (Route<dynamic> route) => false);
  }

  showOverlayGroup(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneGroup(this));
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
    phoneNumberFocusNodeGroup.dispose();
    super.dispose();
  }
}

class InputDoneGroup extends StatelessWidget {
  _SignUpGroupScreenState parent;
  InputDoneGroup(this.parent);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: CupertinoButton(
            padding: EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
            onPressed: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              String year = this.parent._newGroup.text;
              if (year.length != 4) {
                _globals.showErrorAlert(
                    context: context,
                    title: "Error de formato",
                    content: "Debes cargar el años con cuatro digitos",
                    onPressed: () {
                      this.parent._closeDialog;
                      this.parent._newGroup.clear();
                    });
              } else {
                this.parent._createNewYear();
              }
            },
            child: Text("CREAR CAMADA",
                style: TextStyle(
                    color: Colors.blue, //Color(Const.colorPrimary),
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0)),
          ),
        ),
      ),
    );
  }
}
