import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Habit {
  final String name;
  final String frequency; // 'Daily', 'Weekly', 'Monthly'
  final int targetCount; // Daily: 몇번인지, Weekly: 7, Monthly: 주당 몇번인지
  final List<DateTime> completionDates;

  Habit({
    required this.name,
    required this.frequency,
    required this.targetCount,
    required this.completionDates,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'frequency': frequency,
    'targetCount': targetCount,
    'completionDates': completionDates.map((e) => e.toIso8601String()).toList(),
  };

  static Habit fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    frequency: json['frequency'],
    targetCount: json['targetCount'],
    completionDates: (json['completionDates'] as List)
        .map((e) => DateTime.parse(e))
        .toList(),
  );

  static Future<List<Habit>> loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? habitsJson = prefs.getString('habits');
    if (habitsJson == null) {
      return [];
    } else {
      List<dynamic> decoded = jsonDecode(habitsJson);
      return decoded.map((item) => Habit.fromJson(item)).toList();
    }
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(habits.map((habit) => habit.toJson()).toList());
    prefs.setString('habits', encoded);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'frequency': frequency,
      'targetCount': targetCount,
      'completionDates': completionDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      name: map['name'],
      frequency: map['frequency'],
      targetCount: map['targetCount'],
      completionDates: List<DateTime>.from(map['completionDates'].map((date) => DateTime.parse(date))),
    );
  }
}
