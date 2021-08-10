class Pekerjaan {
  int id;
  String nama;
  int idUser;

  Pekerjaan({required this.id, required this.nama, required this.idUser});

  factory Pekerjaan.fromJson(Map<String, dynamic> map) {
    return Pekerjaan(id: map['id'], nama: map['nama'], idUser: map['id_user']);
  }
}
