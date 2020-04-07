import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:curupas/business/auth.dart';
import 'package:curupas/models/group.dart';

class User {
  final String userID;
  final String name;
  final String phone;
  final String birthday;
  final String email;
  final String profilePictureURL;
  final String profilePicture;
  final String thumbnailPictureURL;
  final String thumbnailPicture;
  final LocationData locationData;
  DocumentReference yearRef;
  DocumentReference userRef;
  final DocumentReference roleRef;
  Group group;
  final String nonSpName;
  final bool accepted;
  final int smsCode;
  final int smsId;
  final bool smsChecked;
  String token;

  User(
      {this.userID,
      this.name,
      this.phone,
      this.birthday,
      this.email,
      this.profilePictureURL,
      this.profilePicture,
      this.thumbnailPictureURL,
      this.thumbnailPicture,
      this.locationData,
      this.yearRef,
      this.group,
      this.nonSpName,
      this.accepted,
      this.roleRef,
      this.smsCode,
      this.smsId,
      this.smsChecked,
      this.token});

  Map<String, Object> toJson() {
    GeoPoint geo = GeoPoint(locationData.latitude, locationData.longitude);
    String year;
    if (group != null) {
      year = group.year;
    }
    return {
      'userID': userID,
      'name': name,
      'phone': phone,
      'birthday': birthday,
      'email': email,
      'profilePictureURL': profilePictureURL,
      'profilePicture': profilePicture,
      'thumbnailPictureURL': thumbnailPictureURL,
      'thumbnailPicture': thumbnailPicture,
      'yearRef': yearRef,
      'location': geo,
      'year': year,
      'nonSpName': nonSpName,
      'accepted': accepted,
      'roleRef': roleRef,
      'smsCode': smsCode,
      'smsId': smsId,
      'smsChecked': smsChecked,
      'token': token,
    };
  }

  factory User.fromJson(Map<String, Object> doc) {
    GeoPoint _location = doc['location'];
    Map<String, double> dataMap = {
      'latitude': _location.latitude,
      'longitude': _location.longitude,
    };
    LocationData locData;
    try {
      locData = new LocationData.fromMap(dataMap);
    } on Exception catch (exception) {
      print(exception.toString());
    } catch (error) {
      print(error.toString());
    }
    DocumentReference yearReference = doc['yearRef'];
    User user = new User(
      userID: doc['userID'],
      phone: doc['phone'],
      name: doc['name'],
      birthday: doc['birthday'],
      email: doc['email'],
      profilePictureURL: doc['profilePictureURL'],
      profilePicture: doc['profilePicture'],
      thumbnailPictureURL: doc['thumbnailPictureURL'],
      thumbnailPicture: doc['thumbnailPicture'],
      locationData: locData,
      yearRef: yearReference,
      group: doc['group'],
      nonSpName: doc['nonSpName'],
      accepted: doc['accepted'],
      roleRef: doc['roleRef'],
      smsChecked: doc['smsChecked'],
      token: doc['token'],
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
