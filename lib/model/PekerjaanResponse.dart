import 'package:daily_log/model/Pekerjaan.dart' as model;

class PekerjaanResponse {
  bool success;
  String message;
  List<model.Pekerjaan> data;

  PekerjaanResponse(
      {required this.success, required this.message, required this.data});

  factory PekerjaanResponse.fromJson(Map<String, dynamic> json) {
    return PekerjaanResponse(
        success: json['success'],
        message: json['message'],
        data: List<model.Pekerjaan>.from(json['data'].map((pekerjaan) {
          return model.Pekerjaan.fromJson(pekerjaan);
        })));
  }
}
