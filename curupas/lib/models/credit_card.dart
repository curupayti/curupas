import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'group_media.dart';

class CreditCard {
  final String documentID;
  final String cardNumber;
  final String card;
  final String cardHolder;
  final DateTime expiration_date;

    CreditCard({
    this.documentID,
    this.cardNumber,
    this.card,
    this.cardHolder,
    this.expiration_date,
  });

  Map<String, Object> toJson() {
    return {
      'documentID': documentID,
      'cardNumber': cardNumber,
      'card': card,
      'cardHolder': cardHolder,
      'expiration_date': expiration_date
    };
  }

  factory CreditCard.fromJson(Map<String, Object> doc, String documentID) {

    Timestamp timestamp = doc["last_update"] as Timestamp;
    //var format = new DateFormat('d MMM, hh:mm a');
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    CreditCard noti = new CreditCard(
      documentID: documentID,
      cardNumber: doc['cardNumber'],
      card: doc['card'],
      cardHolder: doc['cardHolder'],
      expiration_date: date,
    );
    return noti;
  }

  factory CreditCard.fromDocument(DocumentSnapshot doc) {
    String documentID = doc.documentID;
    return CreditCard.fromJson(doc.data, documentID);
  }
}
