import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Users.dart';
import 'package:flutter/material.dart';

class UsersProvider extends ChangeNotifier {
  List<Users> _listUsers = [];

  List<Users> get listUsers {
    return _listUsers;
  }

  setListUsers() {
    final notifResponse = ApiService().getListUsers();
    notifResponse.then((value) => _listUsers = value);
    notifyListeners();
  }

  Users getUsers(String idUsers) {
    final notifResponse = ApiService().getListUsers();
    notifResponse.then((value) => _listUsers = value);
    return _listUsers.firstWhere((element) => element.id == idUsers);
  }
}
