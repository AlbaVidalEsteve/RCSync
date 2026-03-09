// lib/models/race_event_model.dart
class RaceEventModel {
  final String id;
  final String name;
  final String location;
  final DateTime date;
  final String? imageUrl;
  final List<String> categories;

  RaceEventModel({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.categories,
  });

  factory RaceEventModel.fromMap(Map<String, dynamic> map) {
    return RaceEventModel(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      date: DateTime.parse(map['event_date']),
      imageUrl: map['image_url'],
      categories: List<String>.from(map['categories'] ?? []),
    );
  }
}