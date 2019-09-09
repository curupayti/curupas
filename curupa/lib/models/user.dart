import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboarding_flow/models/group.dart';

class User {
  final String userID;
  final String name;
  final String birthday;
  final String email;
  final String profilePictureURL;
  DocumentReference groupRef;
  DocumentReference userRef;
  Group group;

  User({
    this.userID,
    this.name,
    this.birthday,
    this.email,
    this.profilePictureURL,
    this.groupRef,
    this.group,
  });

  Map<String, Object> toJson() {
    return {
      'userID': userID,
      'name': name,
      'birthday': birthday,
      'email': email == null ? '' : email,
      'profilePictureURL': profilePictureURL,
      'groupRef': groupRef,
      'group': group,
    };
  }

  factory User.fromJson(Map<String, Object> doc) {
    User user = new User(
      userID: doc['userID'],
      name: doc['name'],
      birthday: doc['birthday'],
      email: doc['email'],
      profilePictureURL: doc['profilePictureURL'],
      groupRef: doc['groupRef'],
    );
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }

  void setGroupReference(DocumentReference ref) {
    groupRef = ref;
  }

  void setUserReference(DocumentReference ref) {
    userRef = ref;
  }

  void createNewGroup(Group _group) {
    this.group = _group;
  }

  Group getGroup() {
    return this.group;
  }
}
