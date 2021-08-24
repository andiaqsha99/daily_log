import 'package:daily_log/model/City.dart';

class CityResponse {
  bool success;
  String message;
  List<City> data;

  CityResponse(
      {required this.success, required this.message, required this.data});

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
        success: json['success'],
        message: json['message'],
        data: List<City>.from(json['data'].map((city) {
          return City.fromJson(city);
        })));
  }
}
