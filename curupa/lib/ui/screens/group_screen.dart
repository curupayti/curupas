import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:onboarding_flow/business/validator.dart';
import 'package:onboarding_flow/models/group.dart';
import 'package:onboarding_flow/ui/widgets/custom_flat_button.dart';
import "package:onboarding_flow/ui/widgets/custom_text_field.dart";
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<DropdownMenuItem<String>> _groupMenuItems = new List();
  List<Group> _groups = new List();
  Group _currentGroup;
  String _currentItem;

  //Cyber Children
  //final TextEditingController _group = new TextEditingController();
  //final TextEditingController _country = new TextEditingController();
  //CustomTextField _groupField;
  //CustomTextField _countryField;

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

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    isUserId();

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

    _loadingInProgress = true;

    getGroupsList().then((val) => setState(() {
          _loadingInProgress = false;
          _groupMenuItems = val;
          print(_groupMenuItems.length);
          _currentItem = _groupMenuItems[0].value;
        }));

    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

  void isUserId() async {
    String userId = await getUserId();
    if (userId != "" && userId != null) {
      _globals.getUserData(userId, false);
    }
  }

  Future<String> getUserId() async {
    prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    return userId;
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
        });
        _saveGroup(context);
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
        await Firestore.instance.collection("groups").getDocuments();
    items.add(new DropdownMenuItem(value: null, child: new Text("----")));
    for (var doc in querySnapshot.documents) {
      String year = doc['year'];
      String documentID = doc.documentID;
      _groups.add(new Group(year: year, documentID: documentID));
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
      return new Center(
        child: new CircularProgressIndicator(),
      );
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
                                    fontSize: 40.0, color: Colors.grey),
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

  void _createNewGroup() async {
    String year = _newGroup.text;
    Auth.checkGroupExist(year).then((result) {
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
        Auth.addGroup(year).then((groupRef) async {
          DocumentSnapshot docsnapshot = await groupRef.get();
          if (docsnapshot.exists) {
            String year = docsnapshot['year'];
            String documentID = docsnapshot.documentID;
            _loadingInProgress = true;
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
    prefs.setBool('group', true);
    String userId = _globals.user.userID;
    String groupId = _currentGroup.documentID;
    String year = _currentGroup.year;

    DocumentReference groupRef =
        Firestore.instance.collection('groups').document(groupId);

    //Upload image
    String toNonSpecial = prefs.getString('toNonSpecial');
    String _imagePath = prefs.getString('_imagePath');
    String imageName = "/users/${year}/${toNonSpecial}";
    String thumbImageName = "/users/${year}/thumb_${toNonSpecial}";

    String _extension = p.extension(_imagePath);
    print(_extension);
    String thumbImageNameExtension = thumbImageName + '$_extension';
    print(thumbImageNameExtension);

    _globals.filePickerGlobal
        .uploadFile(_imagePath, imageName)
        .then((url) async {
      sleep(const Duration(seconds: 1));
      _globals.filePickerGlobal
          .getStorageFileUrl(thumbImageNameExtension)
          .then((thumbnailPictureURL) async {
        Firestore.instance.collection('users').document(userId).updateData({
          'groupRef': groupRef,
          "group": year,
          "profilePictureURL": url,
          "thumbnailPictureURL": thumbnailPictureURL,
        }).then((userUpdated) async {
          _globals.user.groupRef = groupRef;
          _globals.showErrorAlert(
            context: context,
            title: "Registración completa",
            content: "Has completado la registraciónc on éxito. ",
            onPressed: _closeDialog,
          );
        });
      });
    });
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
  _GroupScreenState parent;
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
                this.parent._createNewGroup();
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
