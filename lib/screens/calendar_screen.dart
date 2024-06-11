import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<String> calendars = ['Default'];
  String selectedCalendar = 'Default';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadCalendars();
    }
  }

  void _loadCalendars() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('calendars')
        .doc('list')
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      setState(() {
        calendars = List<String>.from(snapshot['calendars'] ?? ['Default']);
      });
    }
  }

  void _saveCalendars() async {
    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('calendars')
        .doc('list')
        .set({'calendars': calendars});
  }

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
                  _saveCalendars();
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
                  _saveCalendars();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  calendars.removeAt(index);
                  _saveCalendars();
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home');
        return false;
      },
      child: Scaffold(
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
      ),
    );
  }
}
