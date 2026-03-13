class RankingEntry {
  final String idProfile;
  final String fullName;
  final bool isJunior;
  final List<int> points;
  final List<int> positions;

  RankingEntry({
    required this.idProfile,
    required this.fullName,
    required this.isJunior,
    required this.points,
    required this.positions,
  });

  // Puntos Brutos: Suma de TODO
  int get totalGross => points.fold(0, (sum, item) => sum + item);

  // Puntos Netos: Suma de los 4 MEJORES resultados
  int get totalNet {
    if (points.isEmpty) return 0;
    // Ordenamos los puntos de mayor a menor (descendente)
    List<int> sorted = List.from(points)..sort((a, b) => b.compareTo(a));
    // Cogemos solo los 4 primeros (si ha corrido 2, coge 2; si ha corrido 6, coge 4)
    return sorted.take(4).fold(0, (sum, item) => sum + item);
  }

  // Lógica Dinámica Tamiya GT (Se mantiene igual)
  String get calculatedLevel {
    bool hasTop5 = positions.any((p) => p >= 1 && p <= 5);
    if (hasTop5) return "SUPERSTOCK";

    int top10Count = positions.where((p) => p >= 6 && p <= 10).length;
    if (top10Count >= 2) return "SUPERSTOCK";

    return "STOCK";
  }
}