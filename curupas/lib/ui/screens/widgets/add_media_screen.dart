
  import 'dart:ui';

  import 'package:curupas/models/add_media.dart';
  import 'package:curupas/ui/screens/widgets/text_field.dart';
  import 'package:diacritic/diacritic.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:curupas/globals.dart' as _globals;

  class AddMediaScreen extends StatefulWidget {

    final AddMedia addMedia;

    AddMediaScreen({Key key, @required this.addMedia }) : super(key: key);

    @override
    _AddMediaScreenState createState() => _AddMediaScreenState();
  }

  class _AddMediaScreenState extends State<AddMediaScreen> {

    SharedPreferences prefs;

    double _progressValue = 0.0;

    bool loading = false;

    final TextEditingController _titleGroup = new TextEditingController();
    CustomTextField _titleGroupField;
    FocusNode titleFocusNodeGroup = new FocusNode();


    final TextEditingController _descGroup = new TextEditingController();
    CustomTextField _descGroupField;
    FocusNode descFocusNodeGroup = new FocusNode();

    bool _isTitleGroupVisible = true;
    bool _isDescGroupVisible = true;

    bool _isThumbnailVisible = true;

    bool _areButtonsVisible = true;

    @override
    void initState() {
      super.initState();

      getPrefs();

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
      return Scaffold(
        appBar: AppBar(
          title: Text("Second Route"),
        ),
        body: SingleChildScrollView(
          child:
            Center(
              child: Padding(
                padding:
                EdgeInsets.only(top: 10.0, bottom: 2.5, left: 10.0, right: 10.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                      EdgeInsets.only(top: 2.5, bottom: 10, left: 10.0, right: 10.0),
                      child: Visibility(
                        visible: _isTitleGroupVisible,
                        child: new Container(
                          height: 50.0,
                          child: _titleGroupField,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      EdgeInsets.only(top: 6.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Visibility(
                        visible: _isDescGroupVisible,
                        child: new Container(
                          height: 80.0,
                          child: _descGroupField,
                        ),
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
                      padding:
                      EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Container(
                        height: 200,
                        width: 300,
                        child: widget.addMedia.selectedImage,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Visibility(
                        visible: loading,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            LinearProgressIndicator(
                              value: _progressValue,
                            ),
                            Text('${(_progressValue * 100).round()}%'),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _areButtonsVisible,
                      child:
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
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          RaisedButton(
                            color: Colors.blue,
                            onPressed: () {

                              String userId = prefs.getString('userId');
                              String year = _globals.group.year;
                              String documentId = _globals.group.documentID;

                              String name = _globals.user.name.toLowerCase();
                              String toUnderscoreName = name.replaceAll(" ", "-");
                              String diaName = removeDiacritics(toUnderscoreName);
                              int nowTime = new DateTime.now().millisecondsSinceEpoch;
                              String fileName = "${removeDiacritics(diaName)}-${nowTime}";

                              String lowerTitle = _titleGroup.text.toLowerCase();
                              String toUnderscore = lowerTitle.replaceAll(" ", "_");
                              String toNonSpecial = removeDiacritics(toUnderscore);

                              Map<String, String> meta = new Map<String, String>();
                              meta["thumbnail"] = "false";
                              meta["type"] = "4";
                              meta["userId"] = "${userId}";
                              meta["year"] = "${year}";
                              meta["documentId"] = documentId;
                              meta["doc_name_title"] = toNonSpecial;
                              meta["title"] = _titleGroup.text;
                              meta["desc"] = _descGroup.text;

                              StorageMetadata metadata = new StorageMetadata(
                                customMetadata: meta,
                              );

                              String folder = "${year}/${widget.addMedia.type}";

                              //String folder = year;

                              _globals.filePickerGlobal
                                  .uploadFile(widget.addMedia.path, fileName, folder, metadata)
                                  .then((data) async {

                                print(data);
                                /*showDialog(
                                    context: context,
                                    builder: (BuildContext context) => _buildAboutDialog(context),
                                  );*/
                              });
                            },
                            child: Text(
                              '  Cargar  ',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  color: Colors.white),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
      );
    }


  }