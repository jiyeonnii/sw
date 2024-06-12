import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  TextEditingController titleController = TextEditingController();
  List<Habit> habits = [];
  String selectedMood = 'Neutral';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, String>> _diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadHabits();
      _loadDiaryEntries();
    }
  }

  void _loadHabits() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('habits')
        .doc('list')
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      setState(() {
        habits = (snapshot['habits'] as List)
            .map((habit) => Habit.fromMap(habit))
            .toList();
      });
    }
  }

  void _saveHabits() async {
    List<Map<String, dynamic>> habitData =
    habits.map((habit) => habit.toMap()).toList();
    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('habits')
        .doc('list')
        .set({'habits': habitData});
  }

  void _saveDiaryEntry() async {
    if (_user == null) return;

    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('diaryEntries')
        .add({
      'title': titleController.text,
      'mood': selectedMood,
      'entry': entryController.text,
      'date': selectedDay.toIso8601String(),
    });

    _loadDiaryEntries(); // Save 후 목록을 다시 불러옴
  }

  void _loadDiaryEntries() async {
    if (_user == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('diaryEntries')
        .orderBy('date', descending: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _diaryEntries = snapshot.docs
            .map((doc) {
          return {
            'title': doc['title'] ?? '',
            'entry': doc['entry'] ?? '',
            'date': doc['date'] ?? '',
          };
        })
            .map((entry) => Map<String, String>.from(entry))
            .toList();
      });
    }
  }

  void _showDiary(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
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
              if (frequency == 'Daily' || frequency == 'Monthly')
                TextField(
                  controller: countController,
                  decoration: InputDecoration(hintText: 'Times per day'),
                  keyboardType: TextInputType.number,
                ),
              if (frequency == 'Weekly')
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

  void _editHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController habitController =
        TextEditingController(text: habit.name);
        TextEditingController countController = TextEditingController(
            text: habit.frequency == 'Weekly'
                ? '7'
                : habit.targetCount.toString());
        String frequency = habit.frequency;
        return AlertDialog(
          title: Text('Edit Habit'),
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
              if (frequency == 'Daily' || frequency == 'Monthly')
                TextField(
                  controller: countController,
                  decoration: InputDecoration(hintText: 'Times per day'),
                  keyboardType: TextInputType.number,
                ),
              if (frequency == 'Weekly')
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
                  habits = habits.map((h) {
                    if (h == habit) {
                      return Habit(
                        name: habitController.text,
                        frequency: frequency,
                        targetCount: int.parse(countController.text),
                        completionDates: habit.completionDates,
                      );
                    }
                    return h;
                  }).toList();
                  _saveHabits();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  habits.remove(habit);
                  _saveHabits();
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showHabitDetails(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(habit.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Frequency: ${habit.frequency}'),
              Text('Target Count: ${habit.targetCount}'),
              Text('Completion Dates:'),
              ...habit.completionDates.map((date) {
                return Text(date.toIso8601String());
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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

  void _setMood(String mood) {
    setState(() {
      selectedMood = mood;
      _saveDiaryEntry();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home');
        return false;
      },
      child: Scaffold(
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
                        _loadDiaryEntries();
                      });
                  },
                ),
              ),
              ListTile(
                title: TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'Title'),
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
                      color: selectedMood == 'Satisfied'
                          ? Colors.blue
                          : Colors.grey,
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
              ElevatedButton(
                child: Text('Save'),
                onPressed: _saveDiaryEntry,
              ),
              SizedBox(height: 20),
              Text('Diary Entries', style: TextStyle(fontSize: 20)),
              ..._diaryEntries.map((entry) {
                return ListTile(
                  title: Text(entry['title'] ?? ''),
                  onTap: () =>
                      _showDiary(entry['title'] ?? '', entry['entry'] ?? ''),
                );
              }).toList(),
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
                      onTap: () => _showHabitDetails(habit),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editHabit(habit),
                      ),
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
                            value: habit.completionDates.contains(
                                selectedDay.add(Duration(days: index))),
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
                                  habit.completionDates.add(selectedDay
                                      .add(Duration(days: index * 7)));
                                } else {
                                  habit.completionDates.remove(selectedDay
                                      .add(Duration(days: index * 7)));
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
      ),
    );
  }
}
