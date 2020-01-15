import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/content_html.dart';

class DrawerContent {
  final String name;
  final List<ContentHtml> contents;


  DrawerContent.fromMap(Map<dynamic, dynamic> data)
      : name = data["name"],
        contents = List.from(data['contents']);

  DrawerContent({
    this.name,
    this.contents,
  });

  Map<String, Object> toJson() {
    return {
      'name': name,
      'images': contents.toString(),
    };
  }

  factory DrawerContent.fromJson(Map<String, Object> doc, List<ContentHtml> contents) {
    DrawerContent drawer = new DrawerContent(
      name: doc['name'],
      contents: contents,
    );
    return drawer;
  }

  factory DrawerContent.fromDocument(DocumentSnapshot doc, List<ContentHtml> contents) {
    return DrawerContent.fromJson(doc.data, contents);
  }

  void setGroupReference(DocumentReference ref) {}
}
