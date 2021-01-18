import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String description;
  final List<String> images;
  final String thumbnailSmallUrl;

  Post.fromMap(Map<dynamic, dynamic> data)
      : title = data["title"],
        description = data["description"],
        thumbnailSmallUrl = data["thumbnailSmallUrl"],
        images = List.from(data['images']);

  Post({
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

  factory Post.fromJson(Map<String, Object> doc, List<String> images) {
    Post post = new Post(
      title: doc['title'],
      description: doc['description'],
      images: images,
      thumbnailSmallUrl: doc['thumbnailSmallUrl'],
    );
    return post;
  }

  factory Post.fromDocument(DocumentSnapshot doc, List<String> images) {
    return Post.fromJson(doc.data(), images);
  }

  void setGroupReference(DocumentReference ref) {}
}
