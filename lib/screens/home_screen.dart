// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'add_plan_screen.dart';
import '../models/event.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  List<Event> selectedEvents = [];
  List<String> habits = ['habit 1', 'habit 2'];
  Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    events[selectedDay] = selectedEvents;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              eventLoader: _getEventsForDay,
            ),
            ..._getEventsForDay(selectedDay).map(
                  (event) => ListTile(
                title: Text(event.title),
                subtitle: Text(event.description),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPlanScreen(
                    onAdd: (event) {
                      setState(() {
                        if (events[selectedDay] != null) {
                          events[selectedDay]!.add(event);
                        } else {
                          events[selectedDay] = [event];
                        }
                      });
                    },
                  )),
                );
              },
              child: Text('Add Event'),
            ),
            SizedBox(height: 20),
            Text(
              'Habit Tracker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...habits.map(
                  (habit) => CheckboxListTile(
                title: Text(habit),
                value: false,
                onChanged: (newValue) {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/calendar');
              break;
            case 1:
              Navigator.pushNamed(context, '/budget');
              break;
            case 2:
              Navigator.pushNamed(context, '/home');
              break;
            case 3:
              Navigator.pushNamed(context, '/map');
              break;
            case 4:
              Navigator.pushNamed(context, '/diary');
              break;
          }
        },
      ),
    );
  }
}
