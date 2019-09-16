import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:onboarding_flow/business/validator.dart';
import 'package:onboarding_flow/models/group.dart';
import 'package:onboarding_flow/ui/widgets/custom_alert_dialog.dart';
import 'package:onboarding_flow/ui/widgets/custom_flat_button.dart';
import "package:onboarding_flow/ui/widgets/custom_text_field.dart";
import 'package:onboarding_flow/globals.dart' as _globals;
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

  //Public for being changed via InputDoneGroup
  //CustomFlatButton _createGroupButton;
  CustomFlatButton _saveGroupButton;

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    setButtonEnabled(false);

    phoneNumberFocusNodeGroup.addListener(() {
      bool hasFocus = phoneNumberFocusNodeGroup.hasFocus;
      if (hasFocus)
        showOverlayGroup(context);
      else
        removeOverlay();
    });

    _newGroupField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _newGroup,
      maxLength: 4,
      //fontSize: 20.0,
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
    //}

    _loadingInProgress = true;
    getGroupsList().then((val) => setState(() {
          _loadingInProgress = false;
          _groupMenuItems = val;
          print(_groupMenuItems.length);
          _currentItem = _groupMenuItems[0].value;
          _currentGroup = getGroupById(_currentItem);
        }));

    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

  void enableButton() {
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
                        //color: Colors.grey,
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
                              onChanged: changedGroupItem,
                            )
                          ],
                        )),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 50.0, right: 50.0),
                      child: new Text(
                          "Si tu camada no esta en el menu crea una nueva",
                          style: TextStyle(fontSize: 26.0, color: Colors.grey),
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 50.0, right: 50.0),
                      child: _newGroupField,
                    ),
                    /*Padding(
                      padding: const EdgeInsets.only(
                          top: 30.0, left: 30.0, right: 30.0),
                      //symmetric(vertical: 25.0, horizontal: 40.0),
                      child: _createGroupButton,
                    ),*/
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 30.0, left: 30.0, right: 30.0),
                      //symmetric(vertical: 25.0, horizontal: 40.0),
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

  void changedGroupItem(String selected) {
    setState(() {
      _loadingInProgress = false;
      _currentItem = selected;
      _currentGroup = getGroupById(selected);
    });
  }

  Group getGroupById(String documentId) {
    Group g;
    for (int i = 0; i < _groups.length; i++) {
      if (_groups[i].documentID == documentId) {
        g = _groups[i];
      }
    }
    print(g.year);
    return g;
  }

  void _createNewGroup() async {
    String year = _newGroup.text;
    Auth.checkGroupExist(year).then((result) {
      if (result) {
        _showErrorAlert(
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
            //_groupMenuItems = new List();
            getGroupsList().then((val) /*=> setState(()*/ {
              _newGroup.clear();
              _groupMenuItems = val;
              print(_groupMenuItems.length);
              //_currentGroup = getGroupById(documentID);
              //print(_currentGroup.year);
              //_currentItem = _currentGroup.year;
              //print(_currentItem);
              //_rebuild();
              changedGroupItem(documentID);
            });
          }
        });
      }
    });
  }

  void _saveGroup(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('group', true);

    String userId = _globals.user.userID;
    String groupId = _currentGroup.documentID;

    DocumentReference groupRef =
        Firestore.instance.collection('groups').document(groupId);

    Firestore.instance
        .collection('users')
        .document(userId)
        .updateData({'groupRef': groupRef}).then((userUpdated) async {
      _globals.user.groupRef = groupRef;
      _showErrorAlert(
        title: "Registración completa",
        content: "Has completado la registraciónc on éxito. ",
        onPressed: _closeDialog,
      );
    });
  }

  void _closeDialog() {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  void makeRoutePage({BuildContext context, Widget pageRef}) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => pageRef),
        (Route<dynamic> route) => false);
  }

  void _showErrorAlert({String title, String content, VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: true,
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
    // Clean up the focus node when the Form is disposed.
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
      color: Colors.grey, //Color(Const.doneButtonBg),
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
                this.parent._showErrorAlert(
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
