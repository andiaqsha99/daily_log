import 'package:daily_log/model/Notif.dart';

class NotifResponse {
  bool success;
  String message;
  List<Notif> data;

  NotifResponse(
      {required this.success, required this.message, required this.data});

  factory NotifResponse.fromJson(Map<String, dynamic> json) {
    return NotifResponse(
        success: json['success'],
        message: json['message'],
        data: List<Notif>.from(json['data'].map((notif) {
          return Notif.fromJson(notif);
        })));
  }
}
