import 'dart:ui';

import 'package:curupas/business/cache.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/models/add_media.dart';
import 'package:curupas/ui/widgets/text_field.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMediaScreen extends StatefulWidget {
  final AddMedia addMedia;

  AddMediaScreen({Key key, @required this.addMedia}) : super(key: key);

  @override
  _AddMediaScreenState createState() => _AddMediaScreenState();
}

class _AddMediaScreenState extends State<AddMediaScreen> {
  SharedPreferences prefs;

  bool loading = false;

  final TextEditingController _titleGroup = new TextEditingController();
  CustomTextField _titleGroupField;
  FocusNode titleFocusNodeGroup = new FocusNode();

  final TextEditingController _descGroup = new TextEditingController();
  CustomTextField _descGroupField;
  FocusNode descFocusNodeGroup = new FocusNode();

  int _loadingInProgress = -1;

  String typeCapitol;
  String typeShort;

  @override
  void initState() {
    super.initState();

    getPrefs();

    if (widget.addMedia.typeId == 1) {
      typeCapitol = "NUEVO VIDEO";
      typeShort = "video";
    } else if (widget.addMedia.typeId == 2) {
      typeCapitol = "NUEVA IMAGEN";
      typeShort = "imagen";
    }

    _titleGroupField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _titleGroup,
      style: new TextStyle(
        fontSize: 20.0,
        height: 1.5,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      hint: "Titulo",
      inputType: TextInputType.text,
      focusNode: titleFocusNodeGroup,
    );

    _descGroupField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.red,
      controller: _descGroup,
      maxLength: null,
      style: new TextStyle(
        fontSize: 20.0,
        height: 1.5,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      hint: "Descripción",
      inputType: TextInputType.multiline,
      focusNode: descFocusNodeGroup,
    );

    setState(() {
      _loadingInProgress = 0;
    });

    /*KeyboardVisibilityNotification().addNewListener(
        onChange: (bool visible) {
          if (visible) {
            setState(() {
              _areButtonsVisible = false;
            });
          } else {
            _areButtonsVisible = true;
          }
        },
      );*/
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadingInProgress) {
      case 0:
        return Scaffold(
          appBar: AppBar(
            title: Text(typeCapitol),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 2.5, left: 10.0, right: 10.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 2.5, bottom: 10, left: 10.0, right: 10.0),
                      child: new Container(
                        height: 50.0,
                        child: _titleGroupField,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 6.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: new Container(
                        height: 80.0,
                        child: _descGroupField,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      child: Text(
                        widget.addMedia.title, //"Imagen seleccionada",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Container(
                        height: 200,
                        width: 300,
                        child: widget.addMedia.selectedImage,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.red,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '  Cancelar  ',
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        RaisedButton(
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              _loadingInProgress = 1;
                            });

                            int nowTime =
                                new DateTime.now().millisecondsSinceEpoch;

                            String userId = prefs.getString('userId');
                            String year = Cache.appData.group.year;
                            String documentId =
                                "${Cache.appData.group.documentID}-${nowTime}";

                            String typeId, thumbnail;

                            if (widget.addMedia.typeId == 1) {
                              typeId = "1";
                              thumbnail = "false";
                            } else if (widget.addMedia.typeId == 2) {
                              typeId = "4";
                              thumbnail = "true";
                            }

                            String lowerTitle = _titleGroup.text.toLowerCase();
                            String toUnderscore =
                                lowerTitle.replaceAll(" ", "-");
                            String toNonSpecial =
                                removeDiacritics(toUnderscore);

                            String fileName =
                                "${removeDiacritics(toNonSpecial)}-${nowTime}";

                            Map<String, String> meta =
                                new Map<String, String>();
                            meta["thumbnail"] = thumbnail;
                            meta["type"] = typeId;
                            meta["userId"] = "${userId}";
                            meta["year"] = "${year}";
                            meta["documentId"] = documentId;
                            meta["doc_name_title"] = toNonSpecial;
                            meta["title"] = _titleGroup.text;
                            meta["desc"] = _descGroup.text;

                            SettableMetadata metadata = new SettableMetadata(
                              customMetadata: meta,
                            );

                            String filePath =
                                "${year}/${widget.addMedia.type}/${fileName}";

                            _globals.filePickerGlobal
                                .uploadFile(
                                    widget.addMedia.path, filePath, metadata)
                                .then((completed) async {
                              setState(() {
                                _loadingInProgress = 2;
                                if (widget.addMedia.typeId == 1) {
                                  typeCapitol = "Video subido";
                                } else if (widget.addMedia.typeId == 2) {
                                  typeCapitol = "Imagen subida";
                                }
                              });
                            });
                          },
                          child: Text(
                            '  Cargar  ',
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        break;
      case 1:
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
                    child: widget.addMedia.selectedImage,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: ScreenUtil().setHeight(50.0)),
                  child: new Text(
                    "Subiendo ${typeShort} ${widget.addMedia.title}",
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
        break;
      case 2:
        return Scaffold(
          appBar: AppBar(
            title: Text(typeCapitol),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 2.5, left: 10.0, right: 10.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 2.5, bottom: 10, left: 10.0, right: 10.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(fontSize: 24, color: Colors.grey),
                          text: "Gracias por agregar tu ",
                          children: <TextSpan>[
                            TextSpan(text: widget.addMedia.title.toLowerCase()),
                            TextSpan(text: ". Va a ser revisado en breve."),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: 24, color: Colors.grey),
                        text: "Te recordamos que podes cargar ",
                        children: <TextSpan>[
                          TextSpan(text: " tus historias en la pagina "),
                          TextSpan(
                              text: 'app.curupas.com.ar',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('You clicked on me!');
                                }),
                          TextSpan(
                              text: " entrando con tu usuario y contraseña "),
                          TextSpan(text: " desde tu computadora."),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 6.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: new Container(
                        height: 80.0,
                        child: new Text(
                          "No dejes de compartir contenido.",
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '  VOLVER  ',
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        break;
    }
  }
}
