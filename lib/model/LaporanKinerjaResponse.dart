import 'LaporanKinerja.dart';

class LaporanKinerjaResponse {
  String tanggal;
  List<LaporanKinerja> listLaporanKinerja;

  LaporanKinerjaResponse(
      {required this.tanggal, required this.listLaporanKinerja});

  factory LaporanKinerjaResponse.fromJson(Map<String, dynamic> json) {
    return LaporanKinerjaResponse(
        tanggal: json['tanggal'],
        listLaporanKinerja:
            List<LaporanKinerja>.from(json['subpekerjaan'].map((subpekerjaan) {
          return LaporanKinerja.fromJson(subpekerjaan);
        })));
  }
}
