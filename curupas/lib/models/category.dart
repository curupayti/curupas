import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_media.dart';

class Category {
  final String category;
  final String documentID;
  List<CatgoryMedia> medias;
  final DocumentReference categoryRef;

  Category({this.category, this.documentID, this.categoryRef});

  Map<String, Object> toJson() {
    return {
      'category': category,
      'documentID': documentID,
      'categoryRef': categoryRef
    };
  }

  factory Category.fromJson(Map<String, Object> doc, String documentID,
      DocumentReference categoryRef) {
    Category group = new Category(
      category: doc['category'],
      documentID: documentID,
      categoryRef: categoryRef,
    );
    return group;
  }

  factory Category.fromDocument(DocumentSnapshot doc) {
    String documentID = doc.id;
    DocumentReference categoryRef = doc.reference;
    return Category.fromJson(doc.data(), documentID, categoryRef);
  }
}
