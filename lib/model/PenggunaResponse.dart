import 'package:daily_log/model/Pengguna.dart';

class PenggunaResponse {
  bool success;
  String message;
  List<Pengguna> data;

  PenggunaResponse(
      {required this.success, required this.message, required this.data});

  factory PenggunaResponse.fromJson(Map<String, dynamic> json) {
    return PenggunaResponse(
        success: json['success'],
        message: json['message'],
        data: List<Pengguna>.from(json['data'].map((pengguna) {
          return Pengguna.fromJson(pengguna);
        })));
  }
}
