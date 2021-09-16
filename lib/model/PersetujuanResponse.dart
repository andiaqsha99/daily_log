import 'package:daily_log/model/PersetujuanPekerjaan.dart';

class PersetujuanResponse {
  bool success;
  String message;
  List<PersetujuanPekerjaan> data;

  PersetujuanResponse(
      {required this.success, required this.message, required this.data});

  factory PersetujuanResponse.fromJson(Map<String, dynamic> json) {
    return PersetujuanResponse(
        success: json['success'],
        message: json['message'],
        data: List<PersetujuanPekerjaan>.from(json['data'].map((pekerjaan) {
          return PersetujuanPekerjaan.fromJson(pekerjaan);
        })));
  }
}
