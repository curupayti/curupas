import "package:flutter/material.dart";

class Walkthrough {
  String image;
  String title;
  String description;
  Widget extraWidget;

  Walkthrough({this.image, this.title, this.description, this.extraWidget}) {
    if (extraWidget == null) {
      extraWidget = new Container();
    }
  }
}
