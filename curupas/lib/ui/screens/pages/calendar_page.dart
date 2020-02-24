
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:curupas/business/auth.dart';
  import 'package:curupas/models/event_calendar.dart';
  import 'package:curupas/ui/screens/calendar/event_view.dart';
  import "package:flutter/material.dart";
  import 'package:flutter_speed_dial/flutter_speed_dial.dart';
  import 'package:curupas/globals.dart' as _globals;


  //https://github.com/mattgraham1/FlutterCalendar

  class CalendarPage extends StatefulWidget {
    CalendarPage({Key key}) : super(key: key);
    @override
    _CalendarPageState createState() => _CalendarPageState();
  }

  class _CalendarPageState extends State<CalendarPage> {
    @override
    Widget build(BuildContext context) {
      return Container(
        child: CalendarPageScreen(),
      );
    }

    @override
    void initState() {
      super.initState();
    }
  }

  class CalendarPageScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      double height = MediaQuery.of(context).size.height + 80;
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[Container(height: height, child: CalendarBody())],
          ),
        ),
        floatingActionButton: buildSpeedDial(),
      );
    }
  }

  class CalendarBody extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            UpperSection(),
            CalendarSection(),
          ],
        ),
      );
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

  class UpperSection extends StatelessWidget {

    const UpperSection({
      Key key,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      double button_width = MediaQuery.of(context).size.width / 3;
      return new Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Padding(
          padding: EdgeInsets.only(top: 10.0),
            child:
                new Container(
                  height:40,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.yellow,
                  child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: <Widget>[
                        SizedBox(
                          height: 50.0,
                          width: button_width,
                          child:
                            FlatButton(
                              child: Text("Curupa",
                                style: new TextStyle(
                                  fontSize: 20.0,
                                  height: 1.5,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: (){

                              }
                            ),
                          ),
                          SizedBox(
                            height: 50.0,
                            width: button_width,
                            child:
                              FlatButton(
                                  child: Text("Partidos",
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      height: 1.5,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: (){

                                  }
                              ),
                          ),
                          SizedBox(
                            height: 50.0,
                            width: button_width,
                            child:
                              FlatButton(
                                  child: Text("Camada",
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      height: 1.5,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: (){

                                  }
                              ),
                          ),
                        ],
                      ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  class CalendarSection extends StatefulWidget {
    @override
    _CalendarState createState() => _CalendarState();
  }

  class _CalendarState extends State<CalendarSection> {

    DateTime _dateTime;
    int _beginMonthPadding=0;

    QuerySnapshot _userEventSnapshot;

    _CalendarState() {
      _dateTime = DateTime.now();
      setMonthPadding();
    }

    void setMonthPadding() {
      _beginMonthPadding = new DateTime(_dateTime.year, _dateTime.month, 1).weekday;
      _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
    }

    @override
    Widget build(BuildContext context) {


      final int numWeekDays = 7;
      var size = MediaQuery.of(context).size;

      /*24 is for notification bar on Android*/
      /*28 is for weekday labels of the row*/
      // 55 is for iPhoneX clipping issue.
      final double itemHeight = (size.height - kToolbarHeight-kBottomNavigationBarHeight-24-28-55) / 6;
      final double itemWidth = size.width / numWeekDays;

      return new FutureBuilder(
              future: Auth.getCalendarData(_dateTime).then((snapshot) {
                _userEventSnapshot = snapshot;
              }),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return new LinearProgressIndicator();
                  case ConnectionState.done:
                    return new Column(
                        children: <Widget>[
                          new Column(
                            children: <Widget>[
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new FittedBox(
                                    fit: BoxFit.contain,
                                    child: new Text(
                                      getMonthName(_dateTime.month) + " " + _dateTime.year.toString(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.today,
                                      color: Colors.black,
                                    ),
                                    onPressed: _goToToday
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.chevron_left,
                                      color: Colors.black,
                                    ),
                                    onPressed: _previousMonthSelected
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                    onPressed: _nextMonthSelected
                                  ),
                                ],
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
                                      child: new Text('S',
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline)),
                                  new Expanded(
                                      child: new Text('M',
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline)),
                                  new Expanded(
                                      child: new Text('T',
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline)),
                                  new Expanded(
                                      child: new Text('W',
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline)),
                                  new Expanded(
                                      child: new Text('T',
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline)),
                                  new Expanded(
                                      child: new Text('F',
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline)),
                                  new Expanded(
                                      child: new Text('S',
                                          textAlign: TextAlign.center,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline)),
                                ],
                              ),
                              new GridView.count(
                                crossAxisCount: numWeekDays,
                                childAspectRatio: (itemWidth / itemHeight),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: List.generate(
                                    getNumberOfDaysInMonth(_dateTime.month),
                                      (index) {
                                        int dayNumber = index + 1;
                                        return new GestureDetector(
                                          // Used for handling tap on each day view
                                          onTap: () =>
                                              _onDayTapped(
                                                  dayNumber - _beginMonthPadding),
                                          child: new Container(
                                              margin: const EdgeInsets.all(2.0),
                                              padding: const EdgeInsets.all(1.0),
                                              decoration: new BoxDecoration(
                                                  border: new Border.all(
                                                      color: Colors.grey)),
                                              child: new Column(
                                                children: <Widget>[
                                                  buildDayNumberWidget(dayNumber),
                                                  buildDayEventInfoWidget(dayNumber)
                                                ],
                                              )));
                                    }),
                                  ),
                                ],
                              ),
                            ],
                        );
                    break;
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return new Text('Result: ${snapshot.data}');
                }
              }
          );

    }

    Align buildDayNumberWidget(int dayNumber) {
      //print('buildDayNumberWidget, dayNumber: $dayNumber');
      if ((dayNumber-_beginMonthPadding) == DateTime.now().day
          && _dateTime.month == DateTime.now().month
          && _dateTime.year == DateTime.now().year) {
        // Add a circle around the current day
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 35.0, // Should probably calculate these values
            height: 35.0,
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
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
              dayNumber <= _beginMonthPadding ? ' ' : (dayNumber - _beginMonthPadding).toString(),
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

      _userEventSnapshot.documents.forEach((doc) {
        eventDate = doc.data['time'];
        if (eventDate != null
            && eventDate.day == dayNumber - _beginMonthPadding
            && eventDate.month == _dateTime.month
            && eventDate.year == _dateTime.year) {
          eventCount++;
        }
      });

      if (eventCount > 0) {
        return new Expanded(
          child:
          FittedBox(
            alignment: Alignment.topLeft,
            fit: BoxFit.contain,
            child: new Text(
              "Events:$eventCount",
              maxLines: 1,
              style: new TextStyle(fontWeight: FontWeight.normal,
                  background: Paint()..color = Colors.amberAccent),
            ),
          ),
        );
      } else {
        return new Container();
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
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)
      => new EventsView(new DateTime(_dateTime.year, _dateTime.month, day)))
      );
    }

    void _onFabClicked() {

      DateTime _createDateTime = new DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
          DateTime.now().hour, DateTime.now().minute);
      EventCalendar _event = new EventCalendar("", "",_createDateTime, null);
      Navigator.pushNamed(
        context,
        '/eventcreator',
        arguments: _event,
      );
    }


    Future _onBottomBarItemTapped(int index) async {
      switch(index) {
        case 0:
          break;
        case 1:
          //Navigator.pushNamed(context, Constants.calContactsRoute);
          break;
      }
    }

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


