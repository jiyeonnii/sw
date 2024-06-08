import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/habit.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    // 초기화시 Habit 데이터를 로드합니다.
    _loadHabits();
  }

  void _loadHabits() async {
    List<Habit> loadedHabits = await Habit.loadHabits();
    setState(() {
      habits = loadedHabits;
    });
  }

  void _toggleHabitCompletion(Habit habit, DateTime day) {
    setState(() {
      if (habit.completionDates.contains(day)) {
        habit.completionDates.remove(day);
      } else {
        habit.completionDates.add(day);
      }
      Habit.saveHabits(habits);
    });
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
            ),
            Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                Habit habit = habits[index];
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
                            value: habit.completionDates.contains(selectedDay),
                            onChanged: (bool? value) {
                              _toggleHabitCompletion(habit, selectedDay);
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
                              _toggleHabitCompletion(habit, selectedDay.add(Duration(days: index)));
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
                              _toggleHabitCompletion(habit, selectedDay.add(Duration(days: index * 7)));
                            },
                          );
                        }),
                      ),
                  ],
                );
              },
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
