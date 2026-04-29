class RankingEntry {
  final String idProfile;
  final String fullName;
  final bool isJunior;
  final String calculatedLevel;
  final String? imageProfile;
  final List<int> points;
  final List<int> positions;

  RankingEntry({
    required this.idProfile,
    required this.fullName,
    required this.isJunior,
    required this.calculatedLevel,
    this.imageProfile,
    required this.points,
    required this.positions,
  });

  int get totalGross => points.isNotEmpty ? points.reduce((a, b) => a + b) : 0;

  int get totalNet {
    if (points.isEmpty) return 0;
    List<int> sorted = List.from(points)..sort((a, b) => b.compareTo(a));
    Iterable<int> bestFour = sorted.take(4);
    return bestFour.isEmpty ? 0 : bestFour.reduce((a, b) => a + b);
  }
}