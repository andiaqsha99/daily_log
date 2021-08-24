import 'package:daily_log/model/Presence.dart';

class PresenceResponse {
  bool success;
  String message;
  List<Presence> data;

  PresenceResponse(
      {required this.success, required this.message, required this.data});

  factory PresenceResponse.fromJson(Map<String, dynamic> json) {
    return PresenceResponse(
        success: json['success'],
        message: json['message'],
        data: List<Presence>.from(json['data'].map((presence) {
          return Presence.fromJson(presence);
        })));
  }
}
