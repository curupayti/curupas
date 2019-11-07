import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:onboarding_flow/models/group.dart';

class User {
  final String userID;
  final String name;
  final String phone;
  final String birthday;
  final String email;
  final String profilePictureURL;
  final String thumbnailPictureURL;
  final LocationData locationData;
  DocumentReference yearRef;
  DocumentReference userRef;
  Group group;
  final String nonSpName;

  User({
    this.userID,
    this.name,
    this.phone,
    this.birthday,
    this.email,
    this.profilePictureURL,
    this.thumbnailPictureURL,
    this.locationData,
    this.yearRef,
    this.group,
    this.nonSpName,
  });

  Map<String, Object> toJson() {
    return {
      'userID': userID,
      'name': name,
      'phone': phone,
      'birthday': birthday,
      'email': email == null ? '' : email,
      'profilePictureURL': profilePictureURL,
      'thumbnailPictureURL': thumbnailPictureURL,
      'yearRef': yearRef,
      'location': GeoPoint(locationData.latitude, locationData.longitude),
      'group': group.year,
      'nonSpName': nonSpName,
    };
  }

  factory User.fromJson(Map<String, Object> doc) {
    Map _lm = doc['location'];
    GeoPoint _gp = _lm['geopoint'];
    Map _locationMap = new Map();
    _locationMap['latitude'] = _gp.latitude;
    _locationMap['longitude'] = _gp.longitude;
    User user = new User(
      userID: doc['userID'],
      phone: doc['phone'],
      name: doc['name'],
      birthday: doc['birthday'],
      email: doc['email'],
      profilePictureURL: doc['profilePictureURL'],
      thumbnailPictureURL: doc['thumbnailPictureURL'],
      locationData: new LocationData.fromMap(_locationMap),
      yearRef: doc['yearRef'],
      group: doc['group'],
      nonSpName: doc['nonSpName'],
    );
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }

  void setyearReference(DocumentReference ref) {
    yearRef = ref;
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
