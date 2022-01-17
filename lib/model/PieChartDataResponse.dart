import 'PieChartData.dart';

class PieChartDataResponse {
  bool success;
  String message;
  List<PieChartData> data;

  PieChartDataResponse(
      {required this.success, required this.message, required this.data});

  factory PieChartDataResponse.fromJson(Map<String, dynamic> json) {
    return PieChartDataResponse(
        success: json['success'],
        message: json['message'],
        data: List<PieChartData>.from(json['data'].map((pieChartData) {
          return PieChartData.fromJson(pieChartData);
        })));
  }
}
