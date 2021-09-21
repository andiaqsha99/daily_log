class Kehadiran {
  int hadir;
  int tidakHadir;
  DateTime tanggal;

  Kehadiran(
      {required this.hadir, required this.tidakHadir, required this.tanggal});

  factory Kehadiran.fromJson(Map<String, dynamic> map) {
    return Kehadiran(
        hadir: map['hadir'],
        tidakHadir: map['tidak_hadir'],
        tanggal: DateTime.parse(map['date']));
  }
}
