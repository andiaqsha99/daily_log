import 'dart:convert';

class City {
  int id;
  String city;
  String latitude;
  String longitude;

  City(
      {required this.id,
      required this.city,
      required this.latitude,
      required this.longitude});

  factory City.fromJson(Map<String, dynamic> map) {
    return City(
        id: map['id'],
        city: map['city'],
        latitude: map['latitude'],
        longitude: map['longitude']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "city": city,
      "latitude": latitude,
      "longitude": longitude
    };
  }
}

String cityToJson(City data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}

City cityFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return City.fromJson(data);
}
