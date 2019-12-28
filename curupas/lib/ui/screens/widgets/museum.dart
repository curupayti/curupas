import 'package:flutter/material.dart';

class MuseumWidget extends StatelessWidget {
  final List<String> _alphabets = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 0, 0, 0),
      appBar:
      PreferredSize(
          preferredSize: Size.fromHeight(40.0), // here the desired height
          child:AppBar(
            centerTitle: true,
            backgroundColor: Color.fromRGBO(255, 0, 0, 0),
            title: Text('Museo',
              style: TextStyle(color: Colors.white,
                fontSize: 29.0),),
          ),
      ),
      body: Container(
        height:100,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(8.0),
            scrollDirection: Axis.horizontal,
            children: _alphabets
                .map((data) => CircleAvatar(
                      minRadius: 30.0,
                      backgroundColor: Colors.red,
                      child: Text(data,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.0,
                          )),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
