import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  final String title;
  final String description;
  final List<String> images;
  final String thumbnailUrl;

  Feed.fromMap(Map<dynamic, dynamic> data)
      : title = data["title"],
        description = data["description"],
        thumbnailUrl = data["thumbnailUrl"],
        images = List.from(data['images']);

  Feed({
    this.title,
    this.description,
    this.images,
    this.thumbnailUrl,
  });

  Map<String, Object> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': images.toString(),
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory Feed.fromJson(Map<String, Object> doc) {
    Object imagesObj = doc['images'];
    List<String> images = List.from(imagesObj);
    Feed feed = new Feed(
      title: doc['title'],
      description: doc['description'],
      images: images,
      thumbnailUrl: doc['thumbnailUrl'],
    );
    return feed;
  }

  factory Feed.fromDocument(DocumentSnapshot doc) {
    return Feed.fromJson(doc.data);
  }

  void setGroupReference(DocumentReference ref) {}
}
