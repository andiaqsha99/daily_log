import 'dart:convert';

class Pengguna {
  int id;
  String username;
  String? password;
  String jabatan;
  int positionId;
  int? atasanId;
  String? foto;

  Pengguna(
      {required this.id,
      required this.username,
      required this.password,
      required this.jabatan,
      required this.positionId,
      required this.atasanId,
      this.foto});

  factory Pengguna.fromJson(Map<String, dynamic> map) {
    return Pengguna(
        id: map['id'],
        username: map['username'],
        password: map['password'],
        jabatan: map['jabatan'],
        positionId: map['position_id'],
        atasanId: map['atasan_id'],
        foto: map['foto']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "password": password,
      "jabatan": jabatan,
      "position_id": positionId,
      "atasan_id": atasanId,
      "foto": foto
    };
  }
}

String penggunaToJson(Pengguna data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}

Pengguna penggunaFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return Pengguna.fromJson(data);
}
