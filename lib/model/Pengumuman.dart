import 'dart:convert';

class Pengumuman {
  int id;
  String pengumuman;
  String tanggal;

  Pengumuman(
      {required this.id, required this.pengumuman, required this.tanggal});

  factory Pengumuman.fromJson(Map<String, dynamic> map) {
    return Pengumuman(
        id: map['id'], pengumuman: map['pengumuman'], tanggal: map['tanggal']);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "pengumuman": pengumuman, "tanggal": tanggal};
  }
}

String pengumumanToJson(Pengumuman data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
