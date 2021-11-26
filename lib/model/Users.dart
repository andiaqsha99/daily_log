import 'dart:convert';

class Users {
  String id;
  String name;
  String namaJabatan;
  String? nip;

  Users(
      {required this.id,
      required this.name,
      required this.namaJabatan,
      this.nip});

  factory Users.fromJson(Map<String, dynamic> map) {
    return Users(
        id: map['id'],
        name: map['name'],
        namaJabatan: map['nama_jabatan'],
        nip: map['nip']);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "nama_jabatan": namaJabatan, "nip": nip};
  }
}

String usersToJson(Users data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}

Users usersFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return Users.fromJson(data);
}
