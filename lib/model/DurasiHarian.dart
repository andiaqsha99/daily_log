class DurasiHarian {
  int durasi;
  DateTime tanggal;

  DurasiHarian({required this.durasi, required this.tanggal});

  factory DurasiHarian.fromJson(Map<String, dynamic> map) {
    return DurasiHarian(
        durasi: int.parse(map['durasi']),
        tanggal: DateTime.parse(map['tanggal']));
  }
}
