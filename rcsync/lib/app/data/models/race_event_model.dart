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
  });

  factory RaceEventModel.fromJson(Map<String, dynamic> json) {
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
    );
  }

  static List<RaceEventModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => RaceEventModel.fromJson(item)).toList();
  }
}
