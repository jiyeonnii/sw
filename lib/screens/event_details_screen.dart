// lib/screens/event_details_screen.dart
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final VoidCallback onDelete;
  final Function(Event) onUpdate;

  EventDetailsScreen({required this.event, required this.onDelete, required this.onUpdate});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    descriptionController = TextEditingController(text: widget.event.description);
    selectedDate = widget.event.dateTime;
    selectedTime = TimeOfDay(hour: widget.event.dateTime.hour, minute: widget.event.dateTime.minute);
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _saveChanges() {
    final updatedEvent = Event(
      title: titleController.text,
      description: descriptionController.text,
      dateTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );
    widget.onUpdate(updatedEvent);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            ListTile(
              title: Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickDate,
            ),
            ListTile(
              title: Text('Time: ${selectedTime.format(context)}'),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _pickTime,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
