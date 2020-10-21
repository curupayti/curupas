import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/business/auth.dart';
import 'package:curupas/models/event_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'event_creator.dart';

class EventsView extends StatefulWidget {
  final DateTime _eventDate;
  final String _calendarType;

  EventsView(this._eventDate, this._calendarType);

  @override
  State<StatefulWidget> createState() {
    return EventsViewState(_eventDate, _calendarType);
  }
}

class EventsViewState extends State<EventsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateTime _eventDate;
  final String _calendarType;

  EventsViewState(this._eventDate, this._calendarType);

  Color _getEventColor() {
    if (_calendarType == "camada") {
      return Color(0XFF67ABCC);
    } else if (_calendarType == "curupa") {
      return Color(0XFFF3F3F3);
    } else if (_calendarType == "partidos") {
      return Color(0XFF7986D0);
    } else {
      return Colors.amberAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text(DateFormat("dd MMM yyyy").format(_eventDate)),
      ),
      body: FutureBuilder(
          future: Auth.getCalendarEvents(_eventDate, _calendarType),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return new LinearProgressIndicator();
              case ConnectionState.done:
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else {
                  return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, i) {
                        var document = snapshot.data.documents[i].data;
                        return new GestureDetector(
                            child: new Card(
                              color: _getEventColor(),
                              elevation: 10.0,
                              shape: Border.all(color: Colors.black),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child:
                                    new Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        new Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: new Text(
                                            'Event: ' + document()['name'],
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .headline,
                                          ),
                                        ),
                                        new Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: new Text('Time: ' +
                                              DateFormat("dd MMM yyyy, hh:mm a")
                                                  .format(DateTime
                                                  .fromMicrosecondsSinceEpoch(
                                                  document()['start']
                                                      .microsecondsSinceEpoch)),
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .headline
                                          ),
                                        ),
                                        new Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: new Text('Summary: ' +
                                              document()['summary'],
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .headline5
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
//                                  new Container(
//                                      child: new IconButton(
//                                          iconSize: 30.0,
//                                          padding: EdgeInsets.all(5.0),
//                                          icon: new Icon(Icons.delete),
//                                          )
//                                  ),

                                ],
                              ),
                            )
                        );
                      });
                }
            }
          }
      ),
    );
  }

  void _onCardClicked(DocumentSnapshot document) {
    EventCalendar _event = new EventCalendar(
        document.data()['name'], document.data()['summary'],
        document.data()['time'], document.id);
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new EventCreator(event: _event)));
  }


  void _deleteEvent(DocumentSnapshot document) {
    setState(() {
      //Firestore.instance.collection('calendar_events').document(document.documentID).delete();
    });
  }

  void _onFabClicked() {
    DateTime _createDateTime = new DateTime(
        _eventDate.year, _eventDate.month, _eventDate.day,
        DateTime
            .now()
            .hour, DateTime
        .now()
        .minute);

    EventCalendar _event = new EventCalendar("", "", _createDateTime, null);

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => EventCreator(event: _event)
    )
    );
  }
}