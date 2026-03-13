class RankingEntry {
  final String idProfile;
  final String fullName;
  final bool isJunior;
  final String calculatedLevel; // Recibido directamente de SQL
  final List<int> points;
  final List<int> positions;

  RankingEntry({
    required this.idProfile,
    required this.fullName,
    required this.isJunior,
    required this.calculatedLevel,
    required this.points,
    required this.positions,
  });

  // Puntos Brutos: Suma de todo
  int get totalGross => points.fold(0, (sum, item) => sum + item);

  // Puntos Netos: Suma de los 4 mejores resultados
  int get totalNet {
    if (points.isEmpty) return 0;
    List<int> sorted = List.from(points)..sort((a, b) => b.compareTo(a));
    return sorted.take(4).fold(0, (sum, item) => sum + item);
  }
}