import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:onboarding_flow/business/auth.dart';
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
  final DocumentReference roleRef;
  Group group;
  final String nonSpName;
  final bool approved;
  final int smsCode;
  final int smsId;
  final bool smsChecked;

  User(
      {this.userID,
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
      this.approved,
      this.roleRef,
      this.smsCode,
      this.smsId,
      this.smsChecked});

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
      'thumbnailPictureURL': thumbnailPictureURL,
      'yearRef': yearRef,
      'location': geo,
      'group': year,
      'nonSpName': nonSpName,
      'approved': approved,
      'roleRef': roleRef,
      'smsCode': smsCode,
      'smsId': smsId,
      'smsChecked': smsChecked,
    };
    /*return {
      'userID': userID,
      'name': name,
      'phone': phone,
      'birthday': birthday,
      'email': email == null ? '' : email,
      'profilePictureURL': profilePictureURL,
      'thumbnailPictureURL': thumbnailPictureURL,
      'yearRef': yearRef == null ? '' : yearRef,
      'location': geo == null ? '' : geo,
      'group': year,
      'nonSpName': nonSpName,
      'approved': approved,
      'type': type,
      'smsCode': smsCode,
      'smsId': smsId,
      'smsChecked': smsChecked,
    };*/
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
      thumbnailPictureURL: doc['thumbnailPictureURL'],
      locationData: locData,
      yearRef: yearReference,
      group: doc['group'],
      nonSpName: doc['nonSpName'],
      approved: doc['approved'],
      roleRef: doc['roleRef'],
      smsChecked: doc['smsChecked'],
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
