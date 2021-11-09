import 'package:daily_log/model/Position.dart';

class PositionResponse {
  bool error;
  String message;
  List<Position> data;

  PositionResponse(
      {required this.error, required this.message, required this.data});

  factory PositionResponse.fromJson(Map<String, dynamic> json) {
    return PositionResponse(
        error: json['error'],
        message: json['message'],
        data: List<Position>.from(json['data'].map((position) {
          return Position.fromJson(position);
        })));
  }
}
