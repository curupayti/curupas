import "package:flutter/material.dart";
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

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
    double button_width = (MediaQuery.of(context).size.width / 3) - 10;
    return new Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            height:100,
            width: MediaQuery.of(context).size.width,
            color: Colors.yellow,
            child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                  SizedBox(
                    height: 80.0,
                    width: button_width,
                    child:
                      FlatButton(
                        child: Text("Curupa"),
                        onPressed: (){

                        }
                      ),
                    ),
                    SizedBox(
                      height: 80.0,
                      width: button_width,
                      child:
                        FlatButton(
                            child: Text("Partidoss"),
                            onPressed: (){

                            }
                        ),
                    ),
                    SizedBox(
                      height: 80.0,
                      width: button_width,
                      child:
                        FlatButton(
                            child: Text("Camada"),
                            onPressed: (){

                            }
                        ),
                    ),
                  ],
                ),
            ),
          ),
        ],
      ),
    );
  }
}

//https://www.youtube.com/watch?v=jhtKTKn6PlI
//https://github.com/lohanidamodar/flutter_calendar/tree/part2

class CalendarSection extends StatefulWidget {
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
}

/*class CalendarSection extends StatelessWidget {
  const CalendarSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
          )),],
      ),
    );
  }
}*/
