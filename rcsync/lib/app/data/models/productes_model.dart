import 'dart:ffi';

class Producte {
  int? id;
  int? userId;
  String? producte;
  String? quantitat;
  String? createdAt;
  int? supermercatId;

  Producte({this.id, this.userId,
    this.producte, this.quantitat,
    this.createdAt,
    this.supermercatId});

  Producte.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    producte = json['producte'];
    quantitat = json['quantitat'];
    createdAt = json['created_at'];
    supermercatId = json['supermercat_id'];

  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['producte'] = producte;
    data['quantitat'] = quantitat;
    data['created_at'] = createdAt;
    data['supermercat_id'] = supermercatId;
    return data;
  }

  static List<Producte> fromJsonList(List? data) {
    if (data == null || data.isEmpty) return [];
    return data.map((e) => Producte.fromJson(e)).toList();
  }
}
