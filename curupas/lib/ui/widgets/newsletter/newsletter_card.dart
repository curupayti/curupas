import 'package:curupas/models/HTML.dart';
import 'package:flutter/material.dart';

class NewsletterCard extends StatelessWidget {
  NewsletterCard(this.html);
  final HTML html;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(html.name);
        Navigator.pushNamed(
          context,
          '/contentviewer',
          arguments: html,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(
            left: 12.0,
            top:
            16.0), //EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        decoration: _buildShadowAndRoundedCorners(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(flex: 3, child: _buildThumbnail(context)),
            Flexible(flex: 1, child: _buildInfo()),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildShadowAndRoundedCorners() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: <BoxShadow>[
        BoxShadow(
          spreadRadius: 10.0,
          blurRadius: 30.0,
          color: Colors.black26,
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        children: <Widget>[
          new Container(
            /*color: Colors.red,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/postswipe',
                arguments: feed,
              );
            },*/
            child: Image.network(html.icon),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 4.0, right: 4.0),
          child: Text(
              html.name,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 35.0, left: 4.0, right: 4.0),
          child: Text(
            html.name,
            style: TextStyle(color: Colors.white.withOpacity(0.85)),
          ),
        ),
      ],
    );
  }
}
