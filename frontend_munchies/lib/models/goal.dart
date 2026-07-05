// ignore_for_file: non_constant_identifier_names

class Goal {
  String? user_uid;
  final String? goal_id;
  final int? start_week;
  final DateTime start_date;
  final bool isActive;
  final int quantity;

  Goal({
    this.user_uid,
    this.goal_id,
    this.start_week,
    required this.start_date,
    required this.isActive,
    required this.quantity
  });

  //for ease of creating a new goal for data sent over http
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (user_uid != null) {
      data['user_uid'] = user_uid;
    }
    if (goal_id != null) {
      data['_id'] = goal_id;
    }
    if (start_week != null) {
      data['start_week'] = start_week;
    }
    Map<String, dynamic> required_fields = {
      'start_date': start_date.toIso8601String(),
      'isActive': isActive.toString(),
      'quantity': quantity.toString()
    };
    data.addAll(required_fields);
    return data;
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goal_id: json['_id']?.toString(),
      start_week: int.parse(json['start_week']?.toString() ?? '0'),
      start_date: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()), 
      isActive: bool.parse(json['isActive']?.toString() ?? 'false'), 
      quantity: int.parse(json['quantity']?.toString() ?? '0')
      );
  }

  
}