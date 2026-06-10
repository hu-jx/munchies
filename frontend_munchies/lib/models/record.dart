
// ignore_for_file: non_constant_identifier_names

class Record {
  final String? record_id;
  final String? user_uid;
  String itemName;
  DateTime date;
  int cost;
  String? photo;
  String? category;
  bool isFavourited;
  String? details;
  bool isVisible;

  Record({
    this.record_id,
    this.user_uid,
    required this.itemName,
    required this.date,
    required this.cost,
    this.photo,
    this.category,
    required this.isFavourited,
    this.details,
    required this.isVisible
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      record_id: json['_id']?.toString() ?? '',
      user_uid: json['user_uid']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      date: DateTime.parse(json['date']?.toString() ?? DateTime.now().toIso8601String()).toLocal(),
      cost: int.parse(json['cost']?.toString() ?? "0"),
      isFavourited: bool.parse(json['isFavourited']?.toString() ?? 'false'),
      category: json['category']?.toString(),
      photo: json['photo']?.toString(),
      details: json['details']?.toString(),
      isVisible: bool.parse(json['isVisible']?.toString() ?? 'false')
    );
  }
}