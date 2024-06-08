import 'package:flutter/material.dart';

class AddPlanScreen extends StatelessWidget {
  final DateTime selectedDay;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  AddPlanScreen({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Plan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('Selected Date: ${selectedDay.toLocal()}'),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Plan Name'),
            ),
            TextField(
              controller: memoController,
              decoration: InputDecoration(labelText: 'Memo'),
            ),
            // 알람 설정 UI 추가
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 계획 저장 로직 추가
                Navigator.pop(context);
              },
              child: Text('Save Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
