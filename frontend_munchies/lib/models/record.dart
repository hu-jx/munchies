
// ignore_for_file: non_constant_identifier_names

class Record {
  final String user_uid;
  String itemName;
  DateTime date;
  int cost;
  String? photo;
  String? category;
  bool isFavourited;
  String? details;

  Record({
    required this.user_uid,
    required this.itemName,
    required this.date,
    required this.cost,
    this.photo,
    this.category,
    required this.isFavourited,
    this.details
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      user_uid: json['user_uid']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      date: DateTime.parse(json['date']?.toString() ?? DateTime.now().toIso8601String()),
      cost: int.parse(json['cost']?.toString() ?? "0"),
      isFavourited: bool.parse(json['isFavourited']?.toString() ?? 'false'),
      category: json['category']?.toString(),
      photo: json['photo']?.toString(),
      details: json['details']?.toString()
    );
  }
}