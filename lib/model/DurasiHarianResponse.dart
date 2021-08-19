import 'package:daily_log/model/DurasiHarian.dart';

class DurasiHarianResponse {
  bool success;
  String message;
  List<DurasiHarian> data;

  DurasiHarianResponse(
      {required this.success, required this.message, required this.data});

  factory DurasiHarianResponse.fromJson(Map<String, dynamic> json) {
    return DurasiHarianResponse(
        success: json['success'],
        message: json['message'],
        data: List<DurasiHarian>.from(json['data'].map((durasiHarian) {
          return DurasiHarian.fromJson(durasiHarian);
        })));
  }
}
