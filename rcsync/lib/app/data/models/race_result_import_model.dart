class RaceResultImport {
  final int position;
  final String pilotName;
  final int? transponderNumber;
  final int? laps;
  final String? bestLap;
  final int? points;

  RaceResultImport({
    required this.position,
    required this.pilotName,
    this.transponderNumber,
    this.laps,
    this.bestLap,
    this.points,
  });

  factory RaceResultImport.fromExcel(Map<String, dynamic> row, int index) {
    return RaceResultImport(
      position: index + 1,
      pilotName: row['Nombre']?.toString() ?? row['Pilot Name']?.toString() ?? '',
      transponderNumber: int.tryParse(row['Transponder Nr 1']?.toString() ?? '0'),
      laps: int.tryParse(row['Laps']?.toString() ?? row['Vueltas']?.toString() ?? '0'),
      bestLap: row['Best Lap']?.toString() ?? row['Mejor Vuelta']?.toString(),
      points: int.tryParse(row['Points']?.toString() ?? row['Puntos']?.toString() ?? '0'),
    );
  }
}