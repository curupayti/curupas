import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curupas/models/event_calendar.dart';
import 'package:curupas/ui/screens/calendar/event_view.dart';
import "package:flutter/material.dart";
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

//https://github.com/mattgraham1/FlutterCalendar

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _loading = true;
  int _counting = 0;

  DateTime dateTime;

  bool loading = true;

  Future<QuerySnapshot> futureCalendarSnapshot;
  QuerySnapshot calendarSnapshot;

  int _beginMonthPadding = 0;
  DateTime _dateTime;

  String _calendarSelect = "camada";

  SharedPreferences prefs;

  _CalendarPageState(){
    _dateTime = DateTime.now();
    setMonthPadding();
  }

  void setMonthPadding() {
    _beginMonthPadding =
        new DateTime(_dateTime.year, _dateTime.month, 1).weekday;
    _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
  }

  @override
  void initState()  {
    super.initState();
    String type;
    if (_globals.curupaGuest.isGuest) {
      type = "curupa";
    } else {
      type = "camada";
    }
    getCalendar(type);
  }

  void getCalendar(String _type) async {
    futureCalendarSnapshot = await _globals.getCalendar(_type).then((snapshot) {
      calendarSnapshot = snapshot;
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SpinKitFadingCircle(
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
      );
    } else {
      final int numWeekDays = 7;
      var size = MediaQuery.of(context).size;

      /*24 is for notification bar on Android*/
      /*28 is for weekday labels of the row*/
      // 55 is for iPhoneX clipping issue.

      final double itemHeight = (size.height -
          kToolbarHeight -
          kBottomNavigationBarHeight -
          24 -
          28 -
          55) /
          6;
      final double itemWidth = size.width / numWeekDays;

      double button_width = MediaQuery.of(context).size.width / 3;

      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: new FutureBuilder(
                future: futureCalendarSnapshot,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Container(
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Column(
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                _globals.curupaGuest.isGuest == false ?
                                  SizedBox(
                                    height: 50.0,
                                    width: button_width,
                                    child: FlatButton(
                                        color: _calendarSelect == "camada"
                                            ? _getEventColor()
                                            : Colors.white,
                                        child: Text(
                                          "Camada",
                                          style: new TextStyle(
                                            fontSize: 20.0,
                                            height: 1.5,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          getCalendar("camada");
                                          setState(() {
                                            _calendarSelect = "camada";
                                            loading = true;
                                          });
                                          Timer(Duration(seconds: 3), () {
                                            setState(() {
                                              loading = false;
                                            });
                                          });
                                        }),
                                  ):
                                SizedBox(
                                  height: 50.0,
                                  width: button_width,
                                  child: FlatButton(
                                      color: _calendarSelect == "curupa"
                                          ? _getEventColor()
                                          : Colors.white,
                                      child: Text(
                                        "Curupa",
                                        style: new TextStyle(
                                          fontSize: 20.0,
                                          height: 1.5,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        getCalendar("curupa");
                                        setState(() {
                                          loading = true;
                                          _calendarSelect = "curupa";
                                        });
                                        Timer(Duration(seconds: 3), () {
                                          setState(() {
                                            loading = false;
                                          });
                                        });
                                      }),
                                ),
                                SizedBox(
                                  height: 50.0,
                                  width: button_width,
                                  child: FlatButton(
                                      color: _calendarSelect == "partidos"
                                          ? _getEventColor()
                                          : Colors.white,
                                      child: Text(
                                        "Partidos",
                                        style: new TextStyle(
                                          fontSize: 20.0,
                                          height: 1.5,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        getCalendar("partidos");
                                        setState(() {
                                          loading = true;
                                          _calendarSelect = "partidos";
                                        });
                                        Timer(Duration(seconds: 3), () {
                                          setState(() {
                                            loading = false;
                                          });
                                        });
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                        new Column(
                          children: <Widget>[
                            SizedBox(
                              height: 70.0,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    new Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: new Text(
                                        getMonthNameSpanish(_dateTime.month) +
                                            " " +
                                            _dateTime.year.toString(),
                                        style: new TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.today,
                                          color: Colors.black,
                                          size: 30,
                                        ),
                                        onPressed: _goToToday),
                                    IconButton(
                                        icon: Icon(
                                          Icons.chevron_left,
                                          color: Colors.black,
                                          size: 40,
                                        ),
                                        onPressed: _previousMonthSelected),
                                    IconButton(
                                        icon: Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                          size: 40,
                                        ),
                                        onPressed: _nextMonthSelected),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        new Column(
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Expanded(
                                    child: new Text('D', //'S',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.subtitle)),
                                new Expanded(
                                    child: new Text('L', //'M',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.subtitle)),
                                new Expanded(
                                    child: new Text('M', //'T',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.subtitle)),
                                new Expanded(
                                    child: new Text('M', //'W',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.subtitle)),
                                new Expanded(
                                    child: new Text('J', //'T',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.subtitle)),
                                new Expanded(
                                    child: new Text('V', //'F',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.subtitle)),
                                new Expanded(
                                    child: new Text('S', //'S',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.subtitle)),
                              ],
                            ),
                            new GridView.count(
                              crossAxisCount: numWeekDays,
                              childAspectRatio: (itemWidth / itemHeight),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: List.generate(
                                  getNumberOfDaysInMonth(_dateTime.month), (index) {
                                int dayNumber = index + 1;
                                return new GestureDetector(
                                  // Used for handling tap on each day view
                                  onTap: () => _onDayTapped(
                                      dayNumber - _beginMonthPadding),
                                  child: new Container(
                                    margin: const EdgeInsets.all(2.0),
                                    padding: const EdgeInsets.all(1.0),
                                    decoration: new BoxDecoration(
                                        border: new Border.all(color: Colors.grey)),
                                    child: new Column(
                                      children: <Widget>[
                                        buildDayNumberWidget(dayNumber),
                                        buildDayEventInfoWidget(dayNumber)
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
      );
    }
  }

  Align buildDayNumberWidget(int dayNumber) {
    //print('buildDayNumberWidget, dayNumber: $dayNumber');
    if ((dayNumber - _beginMonthPadding) == DateTime.now().day &&
        _dateTime.month == DateTime.now().month &&
        _dateTime.year == DateTime.now().year) {
      // Add a circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 35.0,
          // Should probably calculate these values
          height: 35.0,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getEventColor(),
            border: Border.all(),
          ),
          child: new Text(
            (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.title,
          ),
        ),
      );
    } else {
      // No circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 35.0, // Should probably calculate these values
          height: 35.0,
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: new Text(
            dayNumber <= _beginMonthPadding
                ? ' '
                : (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      );
    }
  }

  Widget buildDayEventInfoWidget(int dayNumber) {
    int eventCount = 0;
    DateTime eventDate;
    String eventName;
    calendarSnapshot.docs.forEach((doc) {
      eventDate = DateTime.fromMicrosecondsSinceEpoch(
          doc.data()['start'].microsecondsSinceEpoch);
      eventName = doc.data()['name'];
      if (eventDate != null &&
          eventDate.day == dayNumber - _beginMonthPadding &&
          eventDate.month == _dateTime.month &&
          eventDate.year == _dateTime.year) {
        eventCount++;
      }
    });

    if (eventCount > 0) {
      return new Expanded(
        child: FittedBox(
          alignment: Alignment.topLeft,
          fit: BoxFit.contain,
          child: new Text(
            "$eventName",
            maxLines: 1,
            style: new TextStyle(
              fontWeight: FontWeight.normal,
              background: Paint()..color = _getEventColor(),
            ),
          ),
        ),
      );
    } else {
      return new Container();
    }
  }

  Color _getEventColor() {
    if (_calendarSelect == "camada") {
      return Color(0XFF67ABCC);
    } else if (_calendarSelect == "curupa") {
      return Color(0XFFF3F3F3);
    } else if (_calendarSelect == "partidos") {
      return Color(0XFF7986D0);
    } else {
      return Colors.yellowAccent;
    }
  }

  int getNumberOfDaysInMonth(final int month) {
    int numDays = 28;

    // Months are 1, ..., 12
    switch (month) {
      case 1:
        numDays = 31;
        break;
      case 2:
        numDays = 28;
        break;
      case 3:
        numDays = 31;
        break;
      case 4:
        numDays = 30;
        break;
      case 5:
        numDays = 31;
        break;
      case 6:
        numDays = 30;
        break;
      case 7:
        numDays = 31;
        break;
      case 8:
        numDays = 31;
        break;
      case 9:
        numDays = 30;
        break;
      case 10:
        numDays = 31;
        break;
      case 11:
        numDays = 30;
        break;
      case 12:
        numDays = 31;
        break;
      default:
        numDays = 28;
    }
    return numDays + _beginMonthPadding;
  }

  String getMonthNameSpanish(final int month) {
    // Months are 1, ..., 12
    switch (month) {
      case 1:
        return "Enero";
      case 2:
        return "Febrero";
      case 3:
        return "Marzo";
      case 4:
        return "Abril";
      case 5:
        return "Mayo";
      case 6:
        return "Junio";
      case 7:
        return "Julio";
      case 8:
        return "Augosto";
      case 9:
        return "Septiembre";
      case 10:
        return "Octubre";
      case 11:
        return "Noviembre";
      case 12:
        return "Diciembre";
      default:
        return "Unknown";
    }
  }

  String getMonthName(final int month) {
    // Months are 1, ..., 12
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Unknown";
    }
  }

  void _goToToday() {
    print("trying to go to the month of today");
    setState(() {
      _dateTime = DateTime.now();
      setMonthPadding();
    });
  }

  void _previousMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.january)
        _dateTime = new DateTime(_dateTime.year - 1, DateTime.december);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month - 1);
      setMonthPadding();
    });
  }

  void _nextMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.december)
        _dateTime = new DateTime(_dateTime.year + 1, DateTime.january);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month + 1);
      setMonthPadding();
    });
  }

  void _onDayTapped(int day) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (BuildContext context) => new EventsView(
            new DateTime(_dateTime.year, _dateTime.month, day),
            this._calendarSelect),
      ),
    );
  }

  void _onFabClicked() {
    DateTime _createDateTime = new DateTime(_dateTime.year, _dateTime.month,
        _dateTime.day, DateTime.now().hour, DateTime.now().minute);
    EventCalendar _event = new EventCalendar("", "", _createDateTime, null);
    Navigator.pushNamed(
      context,
      '/eventcreator',
      arguments: _event,
    );
  }

  Future _onBottomBarItemTapped(int index) async {
    switch (index) {
      case 0:
        break;
      case 1:
      //Navigator.pushNamed(context, Constants.calContactsRoute);
        break;
    }
  }
}



SpeedDial buildSpeedDial() {
  return SpeedDial(
    marginRight: 25,
    marginBottom: 50,
    animatedIcon: AnimatedIcons.menu_close,
    animatedIconTheme: IconThemeData(size: 22.0),
    visible: true,
    // If true user is forced to close dial manually
    // by tapping main button and overlay is not rendered.
    closeManually: false,
    curve: Curves.bounceIn,
    overlayColor: Colors.black,
    overlayOpacity: 0.5,
    onOpen: () => print('OPENING DIAL'),
    onClose: () => print('DIAL CLOSED'),
    tooltip: 'Menu',
    heroTag: 'speed-dial-hero-tag',
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 8.0,
    shape: CircleBorder(),
    children: [
      SpeedDialChild(
          child: Icon(Icons.edit, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 29, 126, 1),
          label: 'Editar perfil',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('FIRST CHILD')),
    ],
  );
}



//https://www.youtube.com/watch?v=jhtKTKn6PlI
//https://github.com/lohanidamodar/flutter_calendar/tree/part2

/*class CalendarSection extends StatefulWidget {
    @override
    _CalendarState createState() => _CalendarState();
  }

  class _CalendarState extends State<CalendarSection> {
    CalendarController _controller;
    Map<DateTime,List<dynamic>> _events;
    List<dynamic> _selectedEvents;
    TextEditingController _eventController;
    SharedPreferences prefs;

    final Map<DateTime, List> _holidays = {
      DateTime(2019, 1, 1): ['New Year\'s Day'],
      DateTime(2019, 1, 6): ['Epiphany'],
      DateTime(2019, 2, 14): ['Valentine\'s Day'],
      DateTime(2019, 4, 21): ['Easter Sunday'],
      DateTime(2019, 4, 22): ['Easter Monday'],
    };

    @override
    void initState() {
      super.initState();
      _controller = CalendarController();
      _eventController = TextEditingController();
      _events = {};
      _selectedEvents = [];
      initPrefs();
    }

    initPrefs() async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        final _selectedDay = DateTime.now();
        _events = {
          _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
          _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
          _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
          _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
          _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
          _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
          _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
          _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
          _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
          _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
          _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
          _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
          _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
          _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
          _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
        };
      });
    }

    Map<String,dynamic> encodeMap(Map<DateTime,dynamic> map) {
      Map<String,dynamic> newMap = {};
      map.forEach((key,value) {
        newMap[key.toString()] = map[key];
      });
      return newMap;
    }

    Map<DateTime,dynamic> decodeMap(Map<String,dynamic> map) {
      Map<DateTime,dynamic> newMap = {};
      map.forEach((key,value) {
        newMap[DateTime.parse(key)] = map[key];
      });
      return newMap;
    }

    @override
    Widget build(BuildContext context) {
      return
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TableCalendar(
                  events: _events,
                  initialCalendarFormat: CalendarFormat.week,
                  calendarStyle: CalendarStyle(
                      canEventMarkersOverflow: true,
                      todayColor: Colors.orange,
                      selectedColor: Theme.of(context).primaryColor,
                      todayStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white)),
                  headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: TextStyle(color: Colors.white),
                    formatButtonShowsNext: false,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (date, events) {
                    setState(() {
                      _selectedEvents = events;
                    });
                  },
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  calendarController: _controller,
                ),
                ..._selectedEvents.map((event) => ListTile(
                  title: Text(event),
                )),
              ],
            ),
          ),
        );
    }

    _showAddDialog() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: TextField(
              controller: _eventController,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Save"),
                onPressed: (){
                  if(_eventController.text.isEmpty) return;
                  setState(() {
                    if(_events[_controller.selectedDay] != null) {
                      _events[_controller.selectedDay].add(_eventController.text);
                    }else{
                      _events[_controller.selectedDay] = [_eventController.text];
                    }
                    //prefs.setString("events", json.encode(encodeMap(_events)));
                    _eventController.clear();
                    Navigator.pop(context);
                  });
                },
              )
            ],
          )
      );
    }
  }*/
