
  import 'package:curupas/models/HTML.dart';
  import 'package:flutter/material.dart';
  import 'valores_card.dart';

  class ValoresWidget extends StatelessWidget {

    final List<HTML> pumas;

    ValoresWidget({Key key, this.pumas}) : super(key: key);

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
            title: Text('Valores',
              style: TextStyle(color: Colors.white,
                  fontSize: 20.0),),
          ),
        ),
        body: Container(
          height:200,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: buildValoresScroller(),
          ),
        ),
      );
    }

    Widget buildValoresScroller() {
      return
        //Padding(
        //padding: const EdgeInsets.only(top: 16.0),
        //child:
        SizedBox.fromSize(
          size: Size.fromHeight(250.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: pumas.length,
            itemBuilder: (BuildContext context, int index) {
              var puma = pumas[index];
              return ValoresCard(puma);
            },
          ),
        );
    }
  }
