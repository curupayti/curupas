import 'package:curupas/models/HTML.dart';
import 'package:flutter/material.dart';

import 'giras_card.dart';

class GirasWidget extends StatelessWidget {
  final List<HTML> giras;

  GirasWidget({Key key, this.giras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 0, 0, 0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0), // here the desired height
        child: AppBar(
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 0, 0, 0),
          title: Text(
            'Giras',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
      ),
      body: Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: buildGirasScroller(),
        ),
      ),
    );
  }

  Widget buildGirasScroller() {
    return
        //Padding(
        //padding: const EdgeInsets.only(top: 16.0),
        //child:
        SizedBox.fromSize(
      size: Size.fromHeight(250.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: giras.length,
        itemBuilder: (BuildContext context, int index) {
          var newsletter = giras[index];
          return GirasCard(newsletter);
        },
      ),
    );
  }
}
