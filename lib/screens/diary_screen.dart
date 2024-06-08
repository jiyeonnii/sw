// lib/screens/diary_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<String> diaryEntries = [];

  void _addEntry() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController entryController = TextEditingController();
        return AlertDialog(
          title: Text('New Diary Entry'),
          content: TextField(
            controller: entryController,
            decoration: InputDecoration(hintText: 'Enter your thoughts'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  diaryEntries.add(entryController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary'),
      ),
      body: ListView.builder(
        itemCount: diaryEntries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(diaryEntries[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: Icon(Icons.add),
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
