import 'dart:convert';

class SubPekerjaan {
  int id;
  String nama;
  int durasi;
  String tanggal;
  String status;
  String? saran;
  int idPekerjaan;
  int idUser;

  SubPekerjaan(
      {this.id = 0,
      this.nama = '',
      this.durasi = 0,
      this.tanggal = '',
      this.status = '',
      this.saran = '',
      this.idPekerjaan = 0,
      this.idUser = 0});

  factory SubPekerjaan.fromJson(Map<String, dynamic> json) {
    return SubPekerjaan(
        id: json['id'],
        nama: json['nama'],
        durasi: json['durasi'],
        tanggal: json['tanggal'],
        status: json['status'],
        saran: json['saran'],
        idPekerjaan: json['id_pekerjaan'],
        idUser: json['id_user']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama": nama,
      "durasi": durasi,
      "tanggal": tanggal,
      "status": status,
      "saran": saran,
      "id_pekerjaan": idPekerjaan,
      "id_user": idUser
    };
  }
}

String subPekerjaanToJson(SubPekerjaan data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
