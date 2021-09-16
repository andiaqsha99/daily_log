import 'package:daily_log/model/Kehadiran.dart';

class KehadiranResponse {
  bool success;
  String message;
  List<Kehadiran> data;

  KehadiranResponse(
      {required this.success, required this.message, required this.data});

  factory KehadiranResponse.fromJson(Map<String, dynamic> json) {
    return KehadiranResponse(
        success: json['success'],
        message: json['message'],
        data: List<Kehadiran>.from(json['data'].map((kehadiran) {
          return Kehadiran.fromJson(kehadiran);
        })));
  }
}
