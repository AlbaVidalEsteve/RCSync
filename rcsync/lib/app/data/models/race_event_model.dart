class RaceEventModel {
  final int idEvent;
  final int? idChampionship;
  final int? idCircuit;
  final String name;
  final DateTime? eventDateIni;
  final DateTime? eventDateFin;
  final DateTime? eventRegIni;
  final DateTime? eventRegFin;
  final int prize;
  final String? description;
  final String? imageEvent;
  final DateTime? createdAt;

  // Relational data
  final String? circuitName;
  final double? circuitLat;
  final double? circuitLng;
  final String? circuitAddress;
  final String? organizerName;

  RaceEventModel({
    required this.idEvent,
    this.idChampionship,
    this.idCircuit,
    required this.name,
    this.eventDateIni,
    this.eventDateFin,
    this.eventRegIni,
    this.eventRegFin,
    required this.prize,
    this.description,
    this.imageEvent,
    this.createdAt,
    this.circuitName,
    this.circuitLat,
    this.circuitLng,
    this.circuitAddress,
    this.organizerName,
  });

  factory RaceEventModel.fromJson(Map<String, dynamic> json) {
    // Nested data from Supabase joins
    final circuit = json['circuits'];
    final championship = json['championships'];
    final organizer = championship != null ? championship['profiles'] : null;

    return RaceEventModel(
      idEvent: json['id_event'],
      idChampionship: json['id_championship'],
      idCircuit: json['id_circuit'],
      name: json['name'],
      eventDateIni: json['event_date_ini'] != null ? DateTime.parse(json['event_date_ini']) : null,
      eventDateFin: json['event_date_fin'] != null ? DateTime.parse(json['event_date_fin']) : null,
      eventRegIni: json['event_reg_ini'] != null ? DateTime.parse(json['event_reg_ini']) : null,
      eventRegFin: json['event_reg_fin'] != null ? DateTime.parse(json['event_reg_fin']) : null,
      prize: json['prize'] ?? 0,
      description: json['description'],
      imageEvent: json['image_event'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      
      // Map joined fields
      circuitName: circuit != null ? circuit['name'] : null,
      circuitLat: circuit != null ? (circuit['location_lat'] as num?)?.toDouble() : null,
      circuitLng: circuit != null ? (circuit['location_lng'] as num?)?.toDouble() : null,
      circuitAddress: circuit != null ? circuit['address'] : null,
      organizerName: organizer != null ? organizer['full_name'] : null,
    );
  }

  static List<RaceEventModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => RaceEventModel.fromJson(item)).toList();
  }
}
