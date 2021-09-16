import 'package:daily_log/model/SubPekerjaan.dart';

class PersetujuanPekerjaan {
  int id;
  String nama;
  int idUser;
  String tanggal;
  List<SubPekerjaan> subPekerjaan;

  PersetujuanPekerjaan(
      {required this.id,
      required this.nama,
      required this.idUser,
      required this.tanggal,
      required this.subPekerjaan});

  factory PersetujuanPekerjaan.fromJson(Map<String, dynamic> map) {
    return PersetujuanPekerjaan(
        id: map['id'],
        nama: map['nama'],
        idUser: map['id_user'],
        tanggal: map['tanggal'],
        subPekerjaan:
            List<SubPekerjaan>.from(map['subPekerjaan'].map((subpekerjaan) {
          return SubPekerjaan.fromJson(subpekerjaan);
        })));
  }
}
