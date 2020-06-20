
  import 'package:circular_profile_avatar/circular_profile_avatar.dart';
  import 'package:curupas/models/pumas.dart';
  import 'package:flutter/material.dart';

  class PumasWidget extends StatelessWidget {

    final List<Pumas> pumas;

    PumasWidget({Key key, this.pumas}) : super(key: key);

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
              title: Text('Pumas',
                style: TextStyle(color: Colors.white,
                  fontSize: 20.0),),
            ),
        ),
        body: Container(
          height:100,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ListView(
              padding: EdgeInsets.all(2.0),
              scrollDirection: Axis.horizontal,
              children: pumas.map((museum) =>
                  CircularProfileAvatar (
                    museum.thumbnailSmallUrl,
                    radius: 50,
                    //backgroundColor: Colors.transparent,
                    borderWidth: 2,
                    initialsText: Text(
                      museum.title,
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
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
