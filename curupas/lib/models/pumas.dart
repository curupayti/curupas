
  import 'package:cloud_firestore/cloud_firestore.dart';

  class Pumas {
    final String title;
    final String description;
    final List<String> images;
    final String thumbnailSmallUrl;

    Pumas.fromMap(Map<dynamic, dynamic> data)
        : title = data["title"],
          description = data["description"],
          thumbnailSmallUrl = data["thumbnailSmallUrl"],
          images = List.from(data['images']);

    Pumas({
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

    factory Pumas.fromJson(Map<String, Object> doc, List<String> images) {
      Pumas feed = new Pumas(
        title: doc['title'],
        description: doc['description'],
        images: images,
        thumbnailSmallUrl: doc['thumbnailSmallUrl'],
      );
      return feed;
    }

    factory Pumas.fromDocument(DocumentSnapshot doc, List<String> images) {
      return Pumas.fromJson(doc.data, images);
    }

    void setGroupReference(DocumentReference ref) {}
  }
