import 'package:daily_log/model/SubPekerjaan.dart';

class SubPekerjaanResponse {
  bool success;
  String message;
  List<SubPekerjaan> data;

  SubPekerjaanResponse(
      {required this.success, required this.message, required this.data});

  factory SubPekerjaanResponse.fromJson(Map<String, dynamic> json) {
    return SubPekerjaanResponse(
        success: json['success'],
        message: json['message'],
        data: List<SubPekerjaan>.from(json['data'].map((subpekerjaan) {
          return SubPekerjaan.fromJson(subpekerjaan);
        })));
  }
}
