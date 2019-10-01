import "package:flutter/material.dart";
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:onboarding_flow/globals.dart' as _globals;

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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ProfilePageScreen(),
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
  }
}

class ProfilePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height + 100;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[Container(height: height, child: ProfileBody())],
        ),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }
}

class ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          UpperSection(),
          MiddleSection(),
        ],
      ),
    );
  }
}

SpeedDial buildSpeedDial() {
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
}

class UpperSection extends StatelessWidget {
  const UpperSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              new Stack(fit: StackFit.loose, children: <Widget>[
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            image: new NetworkImage(
                                _globals.user.profilePictureURL),
                            fit: BoxFit.cover,
                          )),
                    ),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(top: 110.0, right: 90.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 30.0,
                          child: new Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        )
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

class MiddleSection extends StatelessWidget {
  const MiddleSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
    );
  }
}
