import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/bottom_nav_bar.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.5665, 126.9780); // 서울 좌표
  List<String> categories = ['Food', 'Cafe', 'Market', 'Photo'];
  List<Map<String, String>> locations = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController categoryController = TextEditingController();
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(hintText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  categories.add(categoryController.text);
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

  void _addLocation(String category) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController addressController = TextEditingController();
        TextEditingController memoController = TextEditingController();
        return AlertDialog(
          title: Text('Add Location to $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Location Name'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(hintText: 'Address'),
              ),
              TextField(
                controller: memoController,
                decoration: InputDecoration(hintText: 'Memo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  locations.add({
                    'category': category,
                    'name': nameController.text,
                    'address': addressController.text,
                    'memo': memoController.text,
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

  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final LatLng target = LatLng(location.latitude, location.longitude);
        mapController.animateCamera(CameraUpdate.newLatLng(target));
      }
    } catch (e) {
      // Handle the error here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final String? query = await showSearch(
                context: context,
                delegate: LocationSearchDelegate(),
              );
              if (query != null && query.isNotEmpty) {
                _searchLocation(query);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addCategory,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.folder),
                  title: Text(categories[index]),
                  onTap: () => _addLocation(categories[index]),
                );
              },
            ),
          ),
        ],
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

class LocationSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
