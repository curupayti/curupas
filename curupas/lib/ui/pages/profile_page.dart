  import 'dart:io';

  import 'package:curupas/models/credit_card.dart';
  import 'package:curupas/ui/widgets/flat_button.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import "package:flutter/material.dart";
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:curupas/globals.dart' as _globals;
  import 'package:flutter_spinkit/flutter_spinkit.dart';

  class ProfilePage extends StatefulWidget {
    ProfilePage({Key key}) : super(key: key);
    @override
    _ProfilePageState createState() => _ProfilePageState();
  }

  var color1 = Color(0xFFa572c0);
  var color2 = Color(0xFF6559d4);
  var profileImage = NetworkImage(
      'https://static1.squarespace.com/static/55f45174e4b0fb5d95b07f39/t/5aec4511aa4a991e53e6c044/1525433627644/Alexandra+Agoston+archives.jpg?format=1000w');

  bool _status = true;

  final TextEditingController _fullnameController = new TextEditingController();
  final TextEditingController _groupController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _phoneController = new TextEditingController();
  final TextEditingController _birthdayController = new TextEditingController();

  class _ProfilePageState extends State<ProfilePage> {

    DecorationImage _avatarImage;

    bool _loading = true;
    int _counting = 0;

    @override
    Widget build(BuildContext context) {
      return Container(
        child: ProfilePageScreen(this, _loading),
      );
    }

    @override
    void initState() {
      super.initState();
      _fullnameController.text = _globals.user.name;
      _groupController.text = _globals.group.year;
      _emailController.text = _globals.user.email;
      _phoneController.text = _globals.user.phone;
      _birthdayController.text = _globals.user.birthday;

      _avatarImage = new DecorationImage(
        image: new NetworkImage(_globals.user.thumbnailPictureURL),
        fit: BoxFit.cover,
      );

      _globals.getNotifications();

      _globals.eventBus.on().listen((event) {
        String _event = event.toString();
        if (_event.contains("profile")) {
          _counting = _counting + 1;
          if (_counting == 1) {
            _globals.setDataFromGlobal();
            _counting = 0;
            setState(() {
              _loading = false;
            });
          }
        }
        print("Counting : ${_counting}");
      });
    }
  }

  class ProfilePageScreen extends StatelessWidget {

    _ProfilePageState parent;

    final bool loading;

    ProfilePageScreen(this.parent, this.loading);

    Widget build(BuildContext context) {


      if (loading) {

        return SpinKitFadingCircle(
          itemBuilder: (BuildContext context, int index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: index.isEven ? Colors.red : Colors.green,
              ),
            );
          },
        );

      } else {

        return DefaultTabController(
            length: 3,
            child: Scaffold(
  //                appBar: AppBar(
  //                  title: Text(title),
  //                ),
                body: SafeArea(
                    child: Column(children: <Widget>[
                      Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height / 2.8,  // Also Including Tab-bar height.
                          child: UpperSection(parent),
                      ),
                      PreferredSize(
                        preferredSize: Size.fromHeight(50.0),
                        child: TabBar(
                          labelColor: Colors.black,
                          tabs: [
                            Tab(icon: Icon(Icons.notifications)),
                            Tab(icon: Icon(Icons.payment)),
                            Tab(icon: Icon(Icons.info)),
                          ], // list of tabs
                        ),
                      ),
                      //TabBarView(children: [ImageList(),])
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.blue],
                              //begin: Alignment.topCenter,
                              //end:Alignment.bottomCenter
                            )),
                            child:
                              TabBarView(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: renderNotifications(context),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: CreditCardBody(parent),
                                  ),
                                  Container(
                                    color: Colors.yellowAccent,
                                    child: ProfileDataBody(parent),
                                  ) // class name
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
        );
      }
    }

    renderNotifications(BuildContext context) {
      return ListView.builder(
        itemCount: _globals.notifications.length,
        itemBuilder: _getItemUI,
        padding: EdgeInsets.all(0.0),
      );
    }

    Widget _getItemUI(BuildContext context, int index) {
      return new Card(
          child: new Column(
            children: <Widget>[
              new ListTile(
                /*leading: new Image.asset(
                  "assets/" + _globals.notifications[index].image,
                  fit: BoxFit.cover,
                  width: 100.0,
                ),*/
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(_globals.notifications[index].thumbnailImageURL),
                ),

                title: new Text(
                  _globals.notifications[index].title,
                  style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                subtitle: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(_globals.notifications[index].notification,
                          style: new TextStyle(
                              fontSize: 13.0, fontWeight: FontWeight.normal)),
                      new Text('Population: "5',
                          style: new TextStyle(
                              fontSize: 11.0, fontWeight: FontWeight.normal)),
                    ]),

                onTap: () {

                },
              )
            ],
          ));
    }
  }

  class ProfileDataBody extends StatelessWidget {

    _ProfilePageState parent;

    ProfileDataBody(this.parent);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: ProfileDataWidget(),
      );
    }
  }

  /*SpeedDial buildSpeedDial() {
    return SpeedDial(
      marginRight: 25,
      marginBottom: 50,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: true,
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Menu',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(Icons.edit, color: Colors.white),
            backgroundColor: Color.fromRGBO(0, 29, 126, 1),
            label: 'Editar perfil',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('FIRST CHILD')),
      ],
    );
  }*/

  class UpperSection extends StatelessWidget {

    _ProfilePageState parent;

    UpperSection(this.parent);

    @override
    Widget build(BuildContext context) {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                new Stack(fit: StackFit.loose, children: <Widget>[
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        width: 120.0,
                        height: 120.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: parent._avatarImage,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 80.0, right: 60.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new GestureDetector(
                            onTap: () {
                              _globals.filePickerGlobal
                                  .getImagePath(FileType.image)
                                  .then((result) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => _buildUpdateDataDialog(context, parent, result),
                                  );

                              });
                            },
                            child: new CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 25.0,
                              child: new Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )),
                ]),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  _globals.user.name,
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildUpdateDataDialog(
      BuildContext context,
      _ProfilePageState parent,
      String result) {

    File _file = new File(result);
    if (_file != null) {

      return new AlertDialog(
        title: new Center(
          child:
            Text('Cambio de avatar',
            style: TextStyle(
                color: Colors.blue, fontSize: ScreenUtil().setSp(40.0))),
        ),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //_buildAboutText(),
            SizedBox(
              height: 16.0,
            ),
            new Center(
              child:
                new Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: new Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        image: new FileImage(_file),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              /*const Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: const Text(
                  'El regreso virtual es crecimiento',
                  style: const TextStyle(fontSize: 15.0),
                ),
              ),*/

          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: new FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              textColor: Colors.white,
              child: Text(
                'CANCELAR',
                style: TextStyle(
                    color: Colors.red, fontSize: ScreenUtil().setSp(40.0)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: new FlatButton(
              onPressed: () {
                updateAvatar(context, parent, _file, result);
              },
              textColor: Colors.white,
              child: Text(
                'ACEPTAR',
                style: TextStyle(
                    color: Colors.green, fontSize: ScreenUtil().setSp(40.0)),
              ),
            ),
          ),
        ],
      );

    }
  }

  void updateAvatar(BuildContext context,
      _ProfilePageState parent,
      File _file,
      String result) {

      Navigator.pop(context);

      int nowTime = new DateTime.now().millisecondsSinceEpoch;

      parent._avatarImage = new DecorationImage(
        image: new FileImage(_file),
        fit: BoxFit.cover,
      );

      String year = _globals.group.year;
      String userId = _globals.user.userID;

      Map<String, String> meta = new Map<String, String>();
      meta["thumbnail"] = "true";
      meta["type"] = "5";
      meta["userId"] = "${userId}";
      meta["profilePictureToDelete"] = _globals.user.profilePicture;
      meta["thumbnailPictureToDelete"] = _globals.user.thumbnailPicture;

      StorageMetadata metadata = new StorageMetadata(
        customMetadata: meta,
      );

      String toNonSpecial = _globals.user.nonSpName;
      String filePath = "${year}/users/${toNonSpecial}-${nowTime}";

      _globals.filePickerGlobal
          .uploadFile(result, filePath, metadata)
          .then((url) {
        parent.setState(() {});
      });
  }

  class ProfileDataWidget extends StatelessWidget {
    const ProfileDataWidget({
      Key key,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      //double _height = 800;
      return SingleChildScrollView(
        child: Container(height: 2000, child:
            Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text(
                            'Nombre',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                          decoration: const InputDecoration(
                            hintText: "Ingresa tu nombre",
                          ),
                          enabled: !_status,
                          autofocus: !_status,
                          controller: _fullnameController,
                        ),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text(
                            'Camada',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                          decoration: const InputDecoration(
                            hintText: "Ingresa tu camada",
                          ),
                          enabled: !_status,
                          autofocus: !_status,
                          controller: _groupController,
                        ),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text(
                            'Email',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                            decoration:
                                const InputDecoration(hintText: "Ingresa tu email"),
                            enabled: !_status,
                            controller: _emailController),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text(
                            'Telefono',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                          decoration: const InputDecoration(
                              hintText: "Ingresa tu telefono"),
                          enabled: !_status,
                          controller: _phoneController,
                        ),
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text(
                            'Fecha de nacimiento',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 110.0, top: 2.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                          decoration: const InputDecoration(
                              hintText: "Ingresa tu fecha de nacimiento"),
                          enabled: !_status,
                          controller: _birthdayController,
                        ),
                      ),
                    ],
                  )),
              ],
            ),
          ),
      );
    }
  }

  class CreditCardBody extends StatelessWidget {

    _ProfilePageState parent;

    CreditCardBody(this.parent);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            CreditCardWidget(parent),
          ],
        ),
      );
    }
  }

  class CreditCardWidget extends StatelessWidget {

    _ProfilePageState parent;

    CreditCardWidget(this.parent);

    @override
    Widget build(BuildContext context) {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(50.0),
            child: Column(
              children: <Widget>[
                new Stack(fit: StackFit.loose, children: <Widget>[
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomFlatButton(
                        title: "Agregar tarjeta",
                        enabled: true,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/creditcard',
                              arguments: new CreditCard(),
                          );
                        },
                        splashColor: Colors.black12,
                        borderColor: Colors.black,
                        borderWidth: 0,
                        color: Colors.red, //
                      ),
                    ],
                  ),
                ]),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  _globals.user.name,
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }
  }
