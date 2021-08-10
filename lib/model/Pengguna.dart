import 'dart:convert';

class Pengguna {
  int id;
  String username;
  String password;
  String jabatan;

  Pengguna(
      {required this.id,
      required this.username,
      required this.password,
      required this.jabatan});

  factory Pengguna.fromJson(Map<String, dynamic> map) {
    return Pengguna(
        id: map['id'],
        username: map['username'],
        password: map['password'],
        jabatan: map['jabatan']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "password": password,
      "jabatan": jabatan
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
