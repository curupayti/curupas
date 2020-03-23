
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:curupas/business/auth.dart';
  import 'package:curupas/models/user.dart';
  import 'package:flutter_speed_dial/flutter_speed_dial.dart';
  import 'package:curupas/globals.dart' as _globals;

  class FriendsListPage extends StatefulWidget {
    @override
    _FriendsListPageState createState() => new _FriendsListPageState();
  }

  class _FriendsListPageState extends State<FriendsListPage> {
    List<User> _friends = [];

    @override
    void initState() {
      super.initState();
      _loadFriends();
    }

    Future<void> _loadFriends() async {
      Auth.getFriends().then((userList) {
        setState(() {
          _friends = userList;
        });
      });
    }

    Widget _buildFriendListTile(BuildContext context, int index) {
      var friend = _friends[index];

      return new ListTile(
        onTap: () => _navigateToFriendDetails(friend, index),
        leading: new Hero(
          tag: index,
          child: new CircleAvatar(
            backgroundImage: new NetworkImage(friend.thumbnailPictureURL),
          ),
        ),
        title: new Text(friend.name),
        subtitle: new Text(friend.phone),
      );
    }

    void _navigateToFriendDetails(User friend, Object avatarTag) {
      /*Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (c) {
            return new FriendDetailsPage(friend, avatarTag: avatarTag);
          },
        ),
      );*/
    }

    @override
    Widget build(BuildContext context) {
      Widget content;

      if (_friends.isEmpty) {
        content = new Center(
          child: new CircularProgressIndicator(),
        );
      } else {
        content = new ListView.builder(
          itemCount: _friends.length,
          itemBuilder: _buildFriendListTile,
        );
      }

      return new Scaffold(
        appBar: new AppBar(title: new Text('Amigos camada ${_globals.group.year}')),
        body: content,
        floatingActionButton: buildSpeedDial(),
      );
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
              label: 'Invitar amigo ${_globals.group.year}',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('FIRST CHILD')),
        ],
      );
    }

  }
