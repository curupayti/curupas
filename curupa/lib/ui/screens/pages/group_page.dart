import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:onboarding_flow/ui/screens/chat/ChatMessageListItem.dart';
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
      child: new ChatScreen(), //FeedDetailsPage(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class ChatScreen extends StatefulWidget {
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
}
