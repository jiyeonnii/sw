// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, String>> places = [];

  void _addPlace() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController addressController = TextEditingController();
        return AlertDialog(
          title: Text('Add Place'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Enter name'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(hintText: 'Enter address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  places.add({
                    'name': nameController.text,
                    'address': addressController.text,
                  });
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
        title: Text('Map'),
      ),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(places[index]['name']!),
            subtitle: Text(places[index]['address']!),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlace,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
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
