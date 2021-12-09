import 'package:daily_log/api/ApiService.dart';
import 'package:flutter/material.dart';

class SettingProvider extends ChangeNotifier {
  int _numBackDate = 0;

  int get numBackDate {
    return _numBackDate;
  }

  setNumBackdate() {
    ApiService().getBackdate().then((value) => _numBackDate = value);
    notifyListeners();
  }
}
