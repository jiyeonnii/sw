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
}
