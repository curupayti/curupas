import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
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

  final TextEditingController _group = new TextEditingController();
  final TextEditingController _country = new TextEditingController();

  CustomTextField _groupField;
  CustomTextField _countryField;

  VoidCallback onBackPress;

  bool _loadingInProgress;

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _loadingInProgress = true;

    getGroupsList().then((val) => setState(() {
          _loadingInProgress = false;
          _groupMenuItems = val;
          _currentItem = _groupMenuItems[0].value;
          _currentGroup = getGroupById(_currentItem);
        }));

    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

  Future<List<DropdownMenuItem<String>>> getGroupsList() async {
    List<DropdownMenuItem<String>> items = new List();
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("groups").getDocuments();
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
                          top: 40.0, bottom: 10.0, left: 10.0, right: 10.0),
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
                          top: 80.0, bottom: 80.0, left: 20.0, right: 20.0),
                      child: new Container(
                        color: Colors.white,
                        child: new Center(
                            child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                                "Selecciona tu camada. Tu grupo de amigos, tu lugar de pertenencia.",
                                style: TextStyle(
                                    fontSize: 26.0, color: Colors.grey),
                                textAlign: TextAlign.center),
                            new Container(
                              padding: new EdgeInsets.only(top: 100.0),
                            ),
                            new DropdownButton(
                              value: _currentItem,
                              items: _groupMenuItems,
                              iconSize: 60.0,
                              style: TextStyle(
                                  fontSize: 35.0, color: Colors.black),
                              onChanged: changedGroupItem,
                            )
                          ],
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 40.0),
                      child: CustomFlatButton(
                        title: "Guardar Camada",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          _saveGroup(context);
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
          ],
        ),
      );
    }
  }

  void changedGroupItem(String selected) {
    setState(() {
      _currentItem = selected;
    });
    _currentGroup = getGroupById(selected);
  }

  Group getGroupById(String documentId) {
    Group g;
    for (int i = 0; i < _groups.length; i++) {
      if (_groups[i].documentID == documentId) {
        g = _groups[i];
      }
    }
    return g;
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
}
