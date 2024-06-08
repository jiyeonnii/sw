import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/bottom_nav_bar.dart';
import '../models/habit.dart';

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime selectedDay = DateTime.now();
  TextEditingController moodController = TextEditingController();
  TextEditingController entryController = TextEditingController();
  List<Habit> habits = [];
  String selectedMood = 'Neutral';

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    List<Habit> loadedHabits = await Habit.loadHabits();
    setState(() {
      habits = loadedHabits;
    });
  }

  void _saveHabits() async {
    await Habit.saveHabits(habits);
  }

  void _addHabit() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController habitController = TextEditingController();
        TextEditingController countController = TextEditingController();
        String frequency = 'Daily';
        return AlertDialog(
          title: Text('Add Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: habitController,
                decoration: InputDecoration(hintText: 'Habit Name'),
              ),
              DropdownButton<String>(
                value: frequency,
                onChanged: (String? newValue) {
                  setState(() {
                    frequency = newValue!;
                  });
                },
                items: <String>['Daily', 'Weekly', 'Monthly']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (frequency == 'Daily')
                TextField(
                  controller: countController,
                  decoration: InputDecoration(hintText: 'Times per day'),
                  keyboardType: TextInputType.number,
                ),
              if (frequency == 'Monthly')
                TextField(
                  controller: countController,
                  decoration: InputDecoration(hintText: 'Times per week'),
                  keyboardType: TextInputType.number,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  int targetCount = 0;
                  if (frequency == 'Daily' || frequency == 'Monthly') {
                    targetCount = int.parse(countController.text);
                  } else if (frequency == 'Weekly') {
                    targetCount = 7;
                  }
                  habits.add(Habit(
                    name: habitController.text,
                    frequency: frequency,
                    targetCount: targetCount,
                    completionDates: [],
                  ));
                  _saveHabits();
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _setMood(String mood) {
    setState(() {
      selectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 기능 구현
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('Select Date'),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDay,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDay)
                    setState(() {
                      selectedDay = picked;
                    });
                },
              ),
            ),
            ListTile(
              title: TextField(
                controller: entryController,
                decoration:
                InputDecoration(hintText: 'Write your daily entry here'),
                maxLines: null,
              ),
            ),
            ListTile(
              title: Text('Set Mood:'),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.sentiment_very_satisfied),
                    color: selectedMood == 'Very Satisfied'
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () => _setMood('Very Satisfied'),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_satisfied),
                    color:
                    selectedMood == 'Satisfied' ? Colors.blue : Colors.grey,
                    onPressed: () => _setMood('Satisfied'),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_neutral),
                    color:
                    selectedMood == 'Neutral' ? Colors.blue : Colors.grey,
                    onPressed: () => _setMood('Neutral'),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_dissatisfied),
                    color: selectedMood == 'Dissatisfied'
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () => _setMood('Dissatisfied'),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_very_dissatisfied),
                    color: selectedMood == 'Very Dissatisfied'
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () => _setMood('Very Dissatisfied'),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Habits'),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: _addHabit,
              ),
            ),
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
                          value: habit.completionDates.contains(selectedDay),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                habit.completionDates.add(selectedDay);
                              } else {
                                habit.completionDates.remove(selectedDay);
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
                          value: habit.completionDates
                              .contains(selectedDay.add(Duration(days: index))),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                habit.completionDates.add(
                                    selectedDay.add(Duration(days: index)));
                              } else {
                                habit.completionDates.remove(
                                    selectedDay.add(Duration(days: index)));
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
                          value: habit.completionDates.contains(
                              selectedDay.add(Duration(days: index * 7))),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                habit.completionDates.add(
                                    selectedDay.add(Duration(days: index * 7)));
                              } else {
                                habit.completionDates.remove(
                                    selectedDay.add(Duration(days: index * 7)));
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
        selectedIndex: 4,
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
