import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Notif.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifProvider extends ChangeNotifier {
  List<Notif> _listNotif = [];

  List<Notif> get listNotif {
    return _listNotif;
  }

  addListNotif(int idUser) {
    List<Notif> newListNotif = [];
    final notifResponse = ApiService().getListNotification(idUser);
    notifResponse.then((value) => newListNotif.addAll(value.data));
    _listNotif = newListNotif;
    notifyListeners();
  }

  onChange() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final idUser = sharedPreferences.getInt("id_user")!;
    addListNotif(idUser);
    notifyListeners();
  }
}

class NotifCounterProvider extends ChangeNotifier {
  int _counter = 0;

  int get counter {
    return _counter;
  }

  addListNotif(int idUser) {
    final notifResponse = ApiService().getUnreadNotification(idUser);
    notifResponse.then((value) {
      _counter = value;
      notifyListeners();
    });
  }

  onChange() async {
    _counter = 0;
    notifyListeners();
  }
}
