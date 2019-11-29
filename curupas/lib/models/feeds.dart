import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String description;
  final List<String> images;
  final String thumbnailUrl;

  Post.fromMap(Map<dynamic, dynamic> data)
      : title = data["title"],
        description = data["description"],
        thumbnailUrl = data["thumbnailUrl"],
        images = List.from(data['images']);

  Post({
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

  factory Post.fromJson(Map<String, Object> doc, List<String> images) {
    Post feed = new Post(
      title: doc['title'],
      description: doc['description'],
      images: images,
      thumbnailUrl: doc['thumbnailUrl'],
    );
    return feed;
  }

  factory Post.fromDocument(DocumentSnapshot doc, List<String> images) {
    return Post.fromJson(doc.data, images);
  }

  void setGroupReference(DocumentReference ref) {}
}
