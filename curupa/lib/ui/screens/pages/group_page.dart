import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:onboarding_flow/globals.dart' as _globals;

var currentUserEmail;
var _scaffoldContext;
DocumentReference userRef;

class GroupPage extends StatefulWidget {
  GroupPage({Key key}) : super(key: key);
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new GroupBody(), //FeedDetailsPage(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class GroupBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          UpperSection(),
          MiddleSection(),
        ],
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      /*floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {},
            backgroundColor: Color.fromRGBO(0, 29, 126, 1),
          ),
        ),
      ),*/
      floatingActionButton: buildSpeedDial(),
    );
  }
}

SpeedDial buildSpeedDial() {
  return SpeedDial(
    // both default to 16
    marginRight: 18,
    marginBottom: 50,
    animatedIcon: AnimatedIcons.menu_close,
    animatedIconTheme: IconThemeData(size: 22.0),
    // this is ignored if animatedIcon is non null
    //child: Icon(Icons.add),
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
          child: Icon(Icons.photo, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 29, 126, 1),
          label: 'Subir imagen',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('FIRST CHILD')),
      SpeedDialChild(
        child: Icon(Icons.video_label, color: Colors.white),
        backgroundColor: Color.fromRGBO(0, 29, 126, 1),
        label: 'Subir Video',
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => print('SECOND CHILD'),
      ),
      SpeedDialChild(
        child: Icon(Icons.calendar_today),
        backgroundColor: Colors.white,
        label: 'Proponer juntada',
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => print('THIRD CHILD'),
      ),
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
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: new Stack(fit: StackFit.loose, children: <Widget>[
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset("assets/images/camadas.png",
                          height: 63.0, width: 300.0, fit: BoxFit.cover),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 100.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(_globals.group.year,
                              style: TextStyle(
                                fontSize: 50.0,
                              )),
                          SizedBox(width: 30.0),
                          new CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 30.0,
                            child: new Icon(
                              Icons.group,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MiddleSection extends StatelessWidget {
  MiddleSection({
    Key key,
  }) : super(key: key);

  TextStyle defaultStyle = TextStyle(fontSize: 24, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: new Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  new Center(
                    child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Flexible(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: defaultStyle,
                                    text:
                                        "Este es un espacio destinado a la camada ",
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: "${_globals.group.year}, ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              " desde sus inicios en infantiles hasta el plantel superior\n\n"),
                                      TextSpan(
                                          text:
                                              "No importa el tiempo que jugaste sino los amigos que hiciste\n\n",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              "En este espacio vas a poder compartir imagenes y videos, organizar juntadas y contar anegdotas que quedaran en la historia del club. Coming soon..",
                                          style: TextStyle(fontSize: 15.0)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

/*class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() {
    return new ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  bool _isComposingMessage = false;

  final referenceMessages =
      FirebaseDatabase.instance.reference().child('messages');

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
      child: new Column(
        children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              query: referenceMessages,
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              sort: (a, b) => b.key.compareTo(a.key),
              //comparing timestamp of messages to check which one would appear first
              itemBuilder: (_, DataSnapshot messageSnapshot,
                  Animation<double> animation, int) {
                return new ChatMessageListItem(
                  messageSnapshot: messageSnapshot,
                  animation: animation,
                );
              },
            ),
          ),
          new Divider(height: 1.0),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
          new Builder(builder: (BuildContext context) {
            _scaffoldContext = context;
            return new Container(width: 0.0, height: 0.0);
          })
        ],
      ),
      decoration: Theme.of(context).platform == TargetPlatform.iOS
          ? new BoxDecoration(
              border: new Border(
                  top: new BorderSide(
              color: Colors.grey[200],
            )))
          : null,
    ));
  }

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      _globals.filePickerGlobal
                          .getImagePath(true)
                          .then((result) {
                        _sendMessage(messageText: null, imageUrl: result);
                      });

                      /*await _ensureLoggedIn();*/
                      /*File imageFile = await ImagePicker.pickImage();
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      StorageReference storageReference = FirebaseStorage
                          .instance
                          .ref()
                          .child("img_" + timestamp.toString() + ".jpg");
                      StorageUploadTask uploadTask =
                          storageReference.put(imageFile);
                      Uri downloadUrl = (await uploadTask.future).downloadUrl;*/
                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textEditingController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isComposingMessage = messageText.length > 0;
                    });
                  },
                  onSubmitted: _textMessageSubmitted,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? getIOSSendButton()
                    : getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });

    //await _ensureLoggedIn();
    //_sendMessage(messageText: text, imageUrl: null);
  }

  void _sendMessage({String messageText, String imageUrl}) {
    referenceMessages.push().set({
      'text': messageText,
      'email': _globals.user.email,
      'imageUrl': imageUrl,
      'userRef': _globals.user.userRef,
      'groupRef': _globals.user.groupRef,
      'senderName': _globals.user.name,
      'senderPhotoUrl': _globals.user.profilePictureURL,
    });

    //analytics.logEvent(name: 'send_message');
  }

  // Example code for sign out.
  /*void _signOut() async {
    await _auth.signOut();
  }*/
}*/
