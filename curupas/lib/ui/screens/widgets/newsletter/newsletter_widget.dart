import 'package:curupas/models/HTML.dart';
import 'package:flutter/material.dart';

import 'newsletter_card.dart';

class NewsletterWidget extends StatelessWidget {

  final List<HTML> newsletters;

  NewsletterWidget({Key key, this.newsletters}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    const hola = "hola";
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 0, 0, 0),
      appBar:
      PreferredSize(
        preferredSize: Size.fromHeight(30.0), // here the desired height
        child:AppBar(
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 0, 0, 0),
          title: Text('Newsletter',
            style: TextStyle(color: Colors.white,
                fontSize: 20.0),),
        ),
      ),
      body: Container(
        height:200,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: buildNewsletterScroller(),
        ),
      ),
    );
  }

  Widget buildNewsletterScroller() {
    return
      //Padding(
      //padding: const EdgeInsets.only(top: 16.0),
      //child:
      SizedBox.fromSize(
        size: Size.fromHeight(250.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: newsletters.length,
          itemBuilder: (BuildContext context, int index) {
            var newsletter = newsletters[index];
            return NewsletterCard(newsletter);
          },
        ),
      );
  }
}
