import 'package:cloud_firestore/cloud_firestore.dart';

class Museum {
  final String title;
  final String description;
  final List<String> images;
  final String thumbnailSmallUrl;

  Museum.fromMap(Map<dynamic, dynamic> data)
      : title = data["title"],
        description = data["description"],
        thumbnailSmallUrl = data["thumbnailSmallUrl"],
        images = List.from(data['images']);

  Museum({
    this.title,
    this.description,
    this.images,
    this.thumbnailSmallUrl,
  });

  Map<String, Object> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': images.toString(),
      'thumbnailSmallUrl': thumbnailSmallUrl,
    };
  }

  factory Museum.fromJson(Map<String, Object> doc, List<String> images) {
    Museum feed = new Museum(
      title: doc['title'],
      description: doc['description'],
      images: images,
      thumbnailSmallUrl: doc['thumbnailSmallUrl'],
    );
    return feed;
  }

  factory Museum.fromDocument(DocumentSnapshot doc, List<String> images) {
    return Museum.fromJson(doc.data, images);
  }

  void setGroupReference(DocumentReference ref) {}
}
