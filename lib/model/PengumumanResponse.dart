import 'package:daily_log/model/Pengumuman.dart';

class PengumumanResponse {
  bool success;
  String message;
  List<Pengumuman> data;

  PengumumanResponse(
      {required this.success, required this.message, required this.data});

  factory PengumumanResponse.fromJson(Map<String, dynamic> json) {
    return PengumumanResponse(
        success: json['success'],
        message: json['message'],
        data: List<Pengumuman>.from(json['data'].map((pengumuman) {
          return Pengumuman.fromJson(pengumuman);
        })));
  }
}
