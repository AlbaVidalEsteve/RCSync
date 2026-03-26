class Transponder {
  final String id;
  final String number;
  final String label;

  Transponder({
    required this.id,
    required this.number,
    required this.label,
  });

  // Factory para crear el objeto desde el JSON de Supabase
  factory Transponder.fromJson(Map<String, dynamic> json) {
    return Transponder(
      id: json['id_transponder']?.toString() ?? '',
      number: json['number']?.toString() ?? 'Sin número',
      label: json['label']?.toString() ?? 'Transponder',
    );
  }

  // Método para convertir a JSON por si necesitas enviar datos
  Map<String, dynamic> toJson() {
    return {
      'id_transponder': id,
      'number': number,
      'label': label,
    };
  }
}