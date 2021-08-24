import 'package:daily_log/model/Position.dart';

class PositionResponse {
  bool success;
  String message;
  List<Position> data;

  PositionResponse(
      {required this.success, required this.message, required this.data});

  factory PositionResponse.fromJson(Map<String, dynamic> json) {
    return PositionResponse(
        success: json['success'],
        message: json['message'],
        data: List<Position>.from(json['data'].map((position) {
          return Position.fromJson(position);
        })));
  }
}
