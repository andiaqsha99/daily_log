class LaporanKinerja {
  int id;
  String nama;
  int durasi;
  String tanggal;
  String status;
  String? saran;
  int idPekerjaan;
  int idUser;
  String namaPekerjaan;

  LaporanKinerja(
      {this.id = 0,
      this.nama = '',
      this.durasi = 0,
      this.tanggal = '',
      this.status = '',
      this.saran = '',
      this.idPekerjaan = 0,
      this.idUser = 0,
      this.namaPekerjaan = ''});

  factory LaporanKinerja.fromJson(Map<String, dynamic> json) {
    return LaporanKinerja(
        id: json['id'],
        nama: json['nama'],
        durasi: json['durasi'],
        tanggal: json['tanggal'],
        status: json['status'],
        saran: json['saran'],
        idPekerjaan: json['id_pekerjaan'],
        idUser: json['id_user'],
        namaPekerjaan: json['nama_pekerjaan']);
  }
}
