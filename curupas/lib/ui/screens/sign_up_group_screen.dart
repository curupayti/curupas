import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/business/auth.dart';
import 'package:curupas/business/cache.dart';
import 'package:curupas/business/validator.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/models/category.dart';
import 'package:curupas/models/group.dart';
import 'package:curupas/ui/widgets/flat_button.dart';
import 'package:curupas/ui/widgets/text_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpGroupScreen extends StatefulWidget {
  @override
  _SignUpGroupScreenState createState() => _SignUpGroupScreenState();
}

class _SignUpGroupScreenState extends State<SignUpGroupScreen> {
  List<DropdownMenuItem<String>> _groupMenuItems = [];
  List<DropdownMenuItem<String>> _categoriesMenuItems = [];
  List<Group> _groups = [];
  List<Category> _categories = [];
  Group _currentGroup;
  Category _currentCategory;
  String _currentGroupItem;
  String _currentCategoryItem;

  final TextEditingController _newCategory = new TextEditingController();
  CustomTextField _newCategoryField;
  Text _newCategoryText;
  bool _isNewCategoryVisible = true;

  final TextEditingController _newGroup = new TextEditingController();
  CustomTextField _newGroupField;
  Text _newGroupText;
  bool _isNewGroupVisible = true;

  OverlayEntry overlayEntry;
  FocusNode phoneNumberFocusNodeGroup = new FocusNode();

  CustomFlatButton _saveGroupButton;

  VoidCallback onBackPress;
  int _loadingInProgress;

  SharedPreferences prefs;

  String curupasUrl = 'https://curupas.com.ar/';

  TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontSize: 25.0,
  );

  TapGestureRecognizer _flutterTapRecognizer;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  void _rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _loadingInProgress = 0;

    _flutterTapRecognizer = new TapGestureRecognizer()
      ..onTap = () => _openUrl(curupasUrl);

    setSaveButtonEnabled(false);

    phoneNumberFocusNodeGroup.addListener(() {
      bool hasFocus = phoneNumberFocusNodeGroup.hasFocus;
      if (hasFocus)
        showOverlayGroup(context);
      else
        removeOverlay();
    });

    _createNewTextCategory("Si sos papa elegi la de tu hijo");

    _newCategoryField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _newCategory,
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

    _createNewTextGroup("Si tu camada no esta en el menu crea una nueva");
    setSaveButtonEnabled(false);

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

    _globals.loadUpdates().then((resultUpdated) async {
      _globals.getGroupsList().then((groups) => setState(() {
            List<DropdownMenuItem<String>> itemsGroup = [];
            for (int i = 0; i < groups.length; i++) {
              String group = groups[i].year;
              itemsGroup.add(
                  new DropdownMenuItem(value: group, child: new Text(group)));
            }
            _groups = groups;
            _loadingInProgress = _loadingInProgress + 1;
            _groupMenuItems = itemsGroup;
            print(_groupMenuItems.length);
            _currentGroupItem = _groupMenuItems[0].value;
          }));
      _globals.getCategoryList().then((categories) => setState(() {
            List<DropdownMenuItem<String>> itemsCategory = [];
            for (int i = 0; i < categories.length; i++) {
              String category = categories[i].documentID;
              itemsCategory.add(new DropdownMenuItem(
                  value: category, child: new Text(category)));
            }
            _categories = categories;
            _loadingInProgress = _loadingInProgress + 1;
            _categoriesMenuItems = itemsCategory;
            print(_categoriesMenuItems.length);
            _currentCategoryItem = _categoriesMenuItems[0].value;
          }));
    });

    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

  void _enableButton() {
    setSaveButtonEnabled(true);
    _rebuild();
  }

  void setSaveButtonEnabled(bool enabled) {
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
          _loadingInProgress = 0;
          _saveGroup(context);
        });
      },
      splashColor: Colors.black12,
      borderColor: borderColor,
      borderWidth: 0,
      color: color, //
    );
  }

  /*Future<List<DropdownMenuItem<String>>> getGroupsList() async {
    List<DropdownMenuItem<String>> items = [];
    QuerySnapshot querySnapshot = await Cache.getCacheCollectionByPath("years");
    items.add(new DropdownMenuItem(value: null, child: new Text("----")));
    for (var doc in querySnapshot.docs) {
      String year = doc['year'];
      String documentID = doc.id;
      if ((year != "invitado") && (year != "admin")) {
        _groups.add(new Group(
            year: year, documentID: documentID, yearRef: doc.reference));
        items.add(
            new DropdownMenuItem(value: documentID, child: new Text(year)));
      }
    }
    print(items.length);
    return items;
  }*/

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
    if (_loadingInProgress == 0) {
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
    } else if (_loadingInProgress == 2) {
      print(_currentGroupItem);
      print(_groupMenuItems.length);
      return new Center(
        child: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            ListView(
              shrinkWrap: true,
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
                  padding:
                      const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
                  child: new Container(
                    child: new Expanded(
                        child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Selecciona una Categoria",
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.grey),
                            textAlign: TextAlign.center),
                        new Container(
                          padding: new EdgeInsets.only(top: 20.0),
                        ),
                        new DropdownButton(
                          value: _currentCategoryItem,
                          items: _categoriesMenuItems,
                          iconSize: 80.0,
                          style: TextStyle(
                              fontSize: 35.0,
                              color: Colors.black,
                              backgroundColor: Colors.white),
                          onChanged: _changedCategoryItem,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, left: 50.0, right: 50.0),
                          child: Visibility(
                            visible: _isNewGroupVisible,
                            child: _newCategoryText,
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
                  child: new Container(
                    child: new Center(
                        child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Selecciona tu camada",
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.grey),
                            textAlign: TextAlign.center),
                        new Container(
                          padding: new EdgeInsets.only(top: 20.0),
                        ),
                        new DropdownButton(
                          value: _currentGroupItem,
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
                  padding: EdgeInsets.only(top: 20.0, left: 50.0, right: 50.0),
                  child: Visibility(
                    visible: _isNewCategoryVisible,
                    child: _newGroupText,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
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
      );
    }
  }

  void _createNewTextGroup(String text) {
    _newGroupText = new Text(text,
        style: TextStyle(fontSize: 26.0, color: Colors.grey),
        textAlign: TextAlign.center);
  }

  void _createNewTextCategory(String text) {
    _newCategoryText = new Text(text,
        style: TextStyle(fontSize: 26.0, color: Colors.grey),
        textAlign: TextAlign.center);
  }

  void _categorySelected(String selected) {
    setState(() {
      _createNewTextCategory(
          "Elegiste la categoria ${selected}, elegi una camada");
      //_isNewCategoryVisible = false;
      _enableButton();
    });
  }

  void _groupSelected(String selected) {
    setState(() {
      _createNewTextGroup(
          "Elegiste la camada ${selected}, pulsa el boton de guardar");
      //_isNewGroupVisible = false;
      _enableButton();
    });
  }

  void _changedCategoryItem(String selected) {
    setState(() {
      //_loadingInProgress = 0;
      _currentCategoryItem = selected;
      if (selected != null) {
        _currentCategory = _getCategoryById(selected);
        String categoryId = _currentCategory.documentID;
        String category = _currentCategory.category;
        print(category);
        print(categoryId);
        _categorySelected(category);
        _enableButton();
      }
    });
  }

  void _changedGroupItem(String selected) {
    setState(() {
      _currentGroupItem = selected;
      if (selected != null) {
        //_loadingInProgress = 0;
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
      String y = _groups[i].year;
      if (y == documentId) {
        g = _groups[i];
      }
    }
    return g;
  }

  Category _getCategoryById(String documentId) {
    Category c;
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].documentID == documentId) {
        c = _categories[i];
      }
    }
    return c;
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
            String documentID = docsnapshot.id;
            setState(() {
              _loadingInProgress = 2;
            });
            _groups = [];
            _globals.getGroupsList().then((groups) {
              List<DropdownMenuItem<String>> itemsGroup = [];
              for (int i = 0; i < groups.length; i++) {
                String group = groups[i].year;
                itemsGroup.add(
                    new DropdownMenuItem(value: group, child: new Text(group)));
              }
              _newGroup.clear();
              _groupMenuItems = itemsGroup;
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
        FirebaseFirestore.instance.collection('years').doc(groupId);

    DocumentReference categoryRef =
        FirebaseFirestore.instance.collection('categories').doc(groupId);

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
      'yearRefs': [yearRef],
      'categoryRef': categoryRef.id,
      'stage': 0
    };
    //remove this
    //prefs.setBool(force_update_user, true);
    Cache.appData.user.isRegistering = true;

    Auth.updateUser(userId, data).then((user) async {
      if (user != null) {
        _fcm.subscribeToTopic('users');
        _fcm.subscribeToTopic(year);

        Map<String, String> meta = new Map<String, String>();
        meta["thumbnail"] = "true";
        meta["type"] = "2";
        meta["userId"] = "${userId}";
        meta["year"] = "${year}";

        SettableMetadata metadata = new SettableMetadata(
          customMetadata: meta,
        );

        _globals.filePickerGlobal
            .uploadFile(_imagePath, filePath, metadata)
            .then((url) {
          Cache.appData.user = user;
          prefs.setBool('group', true);
          prefs.setString('year', year);
          //Cache.appData.user.yearRefs[0] = yearRef;
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
                'Curupas',
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
