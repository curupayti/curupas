
  import 'package:circular_profile_avatar/circular_profile_avatar.dart';
  import 'package:curupas/models/HTML.dart';
  import 'package:flutter/material.dart';

  class AnecdotesWidget extends StatelessWidget {

    final List<HTML> anecdotes;

    AnecdotesWidget({Key key, this.anecdotes}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Color.fromRGBO(255, 0, 0, 0),
        appBar:
        PreferredSize(
            preferredSize: Size.fromHeight(30.0), // here the desired height
            child:AppBar(
              centerTitle: true,
              backgroundColor: Color.fromRGBO(255, 0, 0, 0),
              title: Text('Anecdotas',
                style: TextStyle(color: Colors.white,
                  fontSize: 20.0),),
            ),
        ),
        body: Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ListView(
              padding: EdgeInsets.only(top: 5.0, left: 2.5, right: 2.5),
              scrollDirection: Axis.horizontal,
              children: anecdotes.map((anecdote) =>
                  CircularProfileAvatar (
                    anecdote.icon,
                    radius: 50,
                    //backgroundColor: Colors.transparent,
                    borderWidth: 2,
                    initialsText: Text(
                      anecdote.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          //fontWeight: FontWeight.bold
                      ),
                    ),
                    borderColor: Colors.red,
                    elevation: 5.0,
                    //foregroundColor: Colors.white.withOpacity(0.9),
                    cacheImage: true,
                    onTap: () {
                      print('adil');
                    },
                    showInitialTextAbovePicture: true,
                  ),).toList(),
              ),
            ),
        ),
      );
    }
  }
