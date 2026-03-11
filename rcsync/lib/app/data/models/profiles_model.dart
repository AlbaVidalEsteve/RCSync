import 'package:supabase_notes/app/data/models/profiles_model.dart'; // Asegúrate de tener este import

class RankingEntry {
  final String idProfile;
  final String fullName;
  final bool isJunior;
  final List<int> points; // Lista de puntos de todas las carreras
  final List<int> positions; // Lista de posiciones finales (1-10 son Final A)

  RankingEntry({
    required this.idProfile,
    required this.fullName,
    required this.isJunior,
    required this.points,
    required this.positions,
  });

  // Puntuación Bruta
  int get totalGross => points.fold(0, (sum, item) => sum + item);

  // Puntuación Neta (Descartando el peor resultado)
  int get totalNet {
    if (points.length < 2) return totalGross;
    List<int> sorted = List.from(points)..sort();
    return sorted.skip(1).fold(0, (sum, item) => sum + item);
  }

  // Lógica Dinámica Tamiya GT
  String get calculatedLevel {
    // 1. Queda 1 vez entre los 5 primeros (1º al 5º) de una Final A.
    bool hasTop5 = positions.any((p) => p >= 1 && p <= 5);
    if (hasTop5) return "SUPERSTOCK";

    // 2. Logra meterse en la Final A dos veces consecutivas (6º al 10º).
    // Para simplificar, buscamos si tiene al menos dos Top 10.
    int top10Count = positions.where((p) => p >= 6 && p <= 10).length;
    if (top10Count >= 2) return "SUPERSTOCK";

    return "STOCK";
  }
}