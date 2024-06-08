// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<String> calendars = ['Default'];
  String selectedCalendar = 'Default';

  void _addNewCalendar() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('New Calendar'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Calendar Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  calendars.add(controller.text);
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

  void _editCalendar(int index) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: calendars[index]);
        return AlertDialog(
          title: Text('Edit Calendar'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Calendar Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  calendars[index] = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  calendars.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
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
        title: Text('Calendars'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewCalendar,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: calendars.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(calendars[index]),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _editCalendar(index),
            ),
            onTap: () {
              setState(() {
                selectedCalendar = calendars[index];
              });
              Navigator.pushReplacementNamed(context, '/home', arguments: {'selectedCalendar': selectedCalendar});
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
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
