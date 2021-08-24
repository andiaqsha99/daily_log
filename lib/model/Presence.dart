import 'dart:convert';

class Presence {
  int id;
  int idUser;
  String temperature;
  String conditions;
  String city;
  String latitude;
  String longitude;
  String? notes;
  String date;
  String checkInTime;
  String? checkOutTime;

  Presence(
      {required this.id,
      required this.idUser,
      required this.temperature,
      required this.conditions,
      required this.city,
      required this.latitude,
      required this.longitude,
      required this.date,
      required this.checkInTime,
      this.checkOutTime,
      this.notes});

  factory Presence.fromJson(Map<String, dynamic> map) {
    return Presence(
        id: map['id'],
        idUser: map['id_user'],
        temperature: map['temperature'],
        conditions: map['conditions'],
        city: map['city'],
        latitude: map['latitude'],
        date: map['date'],
        longitude: map['longitude'],
        checkInTime: map['check_in_time'],
        checkOutTime: map['check_out_time'],
        notes: map['notes']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "temperature": temperature,
      "conditions": conditions,
      "city": city,
      "latitude": latitude,
      "longitude": longitude,
      "notes": notes,
      "date": date,
      "check_in_time": checkInTime,
      "check_out_time": checkOutTime,
      "id_user": idUser
    };
  }
}

String presenceToJson(Presence data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}

Presence presenceFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return Presence.fromJson(data);
}
