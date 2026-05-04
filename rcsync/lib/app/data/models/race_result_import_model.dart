class RaceResultImport {
  final int position;
  final String pilotName;
  final int? transponderNumber;
  final int? laps;
  final String? bestLap;
  final int? points;
  final String? idProfile;
  final int? qualyPosition;

  RaceResultImport({
    required this.position,
    required this.pilotName,
    this.transponderNumber,
    this.laps,
    this.bestLap,
    this.points,
    this.idProfile,
    this.qualyPosition,
  });

  factory RaceResultImport.fromExcel(Map<String, dynamic> row, int index) {
    // Excel
    return RaceResultImport(
      position: index + 1,
      pilotName: row['Nombre']?.toString() ?? row['Pilot Name']?.toString() ?? '',
      transponderNumber: int.tryParse(row['Transponder Nr 1']?.toString() ?? '0'),
      laps: int.tryParse(row['Laps']?.toString() ?? row['Vueltas']?.toString() ?? '0'),
      bestLap: row['Best Lap']?.toString() ?? row['Mejor Vuelta']?.toString(),
      points: int.tryParse(row['Points']?.toString() ?? row['Puntos']?.toString() ?? '0'),
      idProfile: null,
      qualyPosition: null,
    );
  }

  // CSV
  factory RaceResultImport.fromCsvRow(Map<String, dynamic> row, int position, {int? qualyPosition}) {
    return RaceResultImport(
      position: position,
      pilotName: row['Piloto']?.toString() ?? '',
      transponderNumber: int.tryParse(row['Transponder']?.toString() ?? '0'),
      laps: int.tryParse(row['Laps']?.toString() ?? row['Vueltas']?.toString() ?? '0'),
      bestLap: row['Best Lap']?.toString() ?? row['Mejor Vuelta']?.toString(),
      points: int.tryParse(row['Points']?.toString() ?? row['Puntos']?.toString() ?? '0'),
      idProfile: row['ID Piloto']?.toString(),
      qualyPosition: qualyPosition,
    );
  }
}