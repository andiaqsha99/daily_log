import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Position.dart';
import 'package:flutter/material.dart';

class PositionProvider extends ChangeNotifier {
  List<Position> _listPosition = [];

  List<Position> get listPosition {
    return _listPosition;
  }

  setListPosition() {
    final notifResponse = ApiService().getPosition();
    notifResponse.then((value) => _listPosition = value.data);
    notifyListeners();
  }

  Position getPosition(int idPosition) {
    return _listPosition
        .firstWhere((element) => element.id == idPosition.toString());
  }
}
