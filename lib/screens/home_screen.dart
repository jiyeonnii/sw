import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/habit.dart';
import '../models/event.dart';
import 'add_plan_screen.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  List<Habit> habits = [];
  List<Event> events = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadHabits();
      _loadEvents();
    }
  }

  void _loadHabits() async {
    if (_user == null) return;

    DocumentSnapshot snapshot = await _firestore.collection('users').doc(_user!.uid).collection('habits').doc('list').get();
    if (snapshot.exists && snapshot.data() != null) {
      setState(() {
        habits = (snapshot['habits'] as List).map((habit) => Habit.fromMap(habit)).toList();
      });
    }
  }

  void _saveHabits() async {
    if (_user == null) return;

    List<Map<String, dynamic>> habitData = habits.map((habit) => habit.toMap()).toList();
    await _firestore.collection('users').doc(_user!.uid).collection('habits').doc('list').set({'habits': habitData});
  }

  void _toggleHabitCompletion(Habit habit, DateTime day) {
    setState(() {
      if (habit.completionDates.contains(day)) {
        habit.completionDates.remove(day);
      } else {
        habit.completionDates.add(day);
      }
      _saveHabits();
    });
  }

  void _loadEvents() async {
    if (_user == null) return;

    QuerySnapshot snapshot = await _firestore.collection('users').doc(_user!.uid).collection('events').get();
    setState(() {
      events = snapshot.docs.map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  void _addEvent(Event event) async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).collection('events').add(event.toMap());
    setState(() {
      events.add(event);
    });
  }

  void _updateEvent(Event updatedEvent) async {
    if (_user == null) return;

    QuerySnapshot snapshot = await _firestore.collection('users').doc(_user!.uid).collection('events').where('dateTime', isEqualTo: updatedEvent.dateTime.toIso8601String()).get();
    if (snapshot.docs.isNotEmpty) {
      await _firestore.collection('users').doc(_user!.uid).collection('events').doc(snapshot.docs.first.id).update(updatedEvent.toMap());
      setState(() {
        events[events.indexWhere((event) => event.dateTime == updatedEvent.dateTime)] = updatedEvent;
      });
    }
  }

  void _deleteEvent(Event event) async {
    if (_user == null) return;

    QuerySnapshot snapshot = await _firestore.collection('users').doc(_user!.uid).collection('events').where('dateTime', isEqualTo: event.dateTime.toIso8601String()).get();
    if (snapshot.docs.isNotEmpty) {
      await _firestore.collection('users').doc(_user!.uid).collection('events').doc(snapshot.docs.first.id).delete();
      setState(() {
        events.removeWhere((e) => e.dateTime == event.dateTime);
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events.where((event) => isSameDay(event.dateTime, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Event> dailyEvents = _getEventsForDay(selectedDay);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/login');
        return false;
      },
      child: Scaffold(
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
              ),
              Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: dailyEvents.length,
                itemBuilder: (context, index) {
                  Event event = dailyEvents[index];
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text('${event.dateTime.hour}:${event.dateTime.minute} - ${event.description}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EventDetailsScreen(
                                  event: event,
                                  onDelete: () => _deleteEvent(event),
                                  onUpdate: (updatedEvent) => _updateEvent(updatedEvent),
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteEvent(event),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddPlanScreen(
                        onAdd: (event) => _addEvent(event),
                      ),
                    ),
                  );
                },
                child: Text('Add Plan'),
              ),
              Divider(),
              ...habits.map((habit) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(habit.name),
                      subtitle: Text(habit.frequency),
                    ),
                    if (habit.frequency == 'Daily')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(habit.targetCount, (index) {
                          return Checkbox(
                            value: habit.completionDates.contains(selectedDay.add(Duration(hours: index))),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  habit.completionDates.add(selectedDay.add(Duration(hours: index)));
                                } else {
                                  habit.completionDates.remove(selectedDay.add(Duration(hours: index)));
                                }
                                _saveHabits();
                              });
                            },
                          );
                        }),
                      ),
                    if (habit.frequency == 'Weekly')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          return Checkbox(
                            value: habit.completionDates.contains(selectedDay.add(Duration(days: index))),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  habit.completionDates.add(selectedDay.add(Duration(days: index)));
                                } else {
                                  habit.completionDates.remove(selectedDay.add(Duration(days: index)));
                                }
                                _saveHabits();
                              });
                            },
                          );
                        }),
                      ),
                    if (habit.frequency == 'Monthly')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(habit.targetCount, (index) {
                          return Checkbox(
                            value: habit.completionDates.contains(selectedDay.add(Duration(days: index * 7))),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  habit.completionDates.add(selectedDay.add(Duration(days: index * 7)));
                                } else {
                                  habit.completionDates.remove(selectedDay.add(Duration(days: index * 7)));
                                }
                                _saveHabits();
                              });
                            },
                          );
                        }),
                      ),
                  ],
                );
              }).toList(),
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
      ),
    );
  }
}
