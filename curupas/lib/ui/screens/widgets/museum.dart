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
      appBar: AppBar(
        title: Text('Museo Curupas por año'),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
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
    );
  }
}
