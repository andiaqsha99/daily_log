class PieChartData {
  String nama;
  int durasi;

  PieChartData({required this.nama, required this.durasi});

  factory PieChartData.fromJson(Map<String, dynamic> map) {
    return PieChartData(
      nama: map['nama'],
      durasi: int.parse(map['durasi']),
    );
  }
}
