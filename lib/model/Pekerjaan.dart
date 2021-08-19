class Pekerjaan {
  int id;
  String nama;
  int idUser;
  String tanggal;

  Pekerjaan(
      {required this.id,
      required this.nama,
      required this.idUser,
      required this.tanggal});

  factory Pekerjaan.fromJson(Map<String, dynamic> map) {
    return Pekerjaan(
        id: map['id'],
        nama: map['nama'],
        idUser: map['id_user'],
        tanggal: map['tanggal']);
  }
}
