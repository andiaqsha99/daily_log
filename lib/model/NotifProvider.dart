import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifProvider with ChangeNotifier {
  List<SubPekerjaan> _listSubPekerjaan = [];
  List<Pengguna> _listPengguna = [];
  int _counter = 0;

  List<SubPekerjaan> get listSubPekerjaan {
    return _listSubPekerjaan;
  }

  List<Pengguna> get listPengguna {
    return _listPengguna;
  }

  int get counter {
    _counter = _listSubPekerjaan.length;
    return _counter;
  }

  addListSubPekerjaan(String jabatan, int idUser, int idPosition) {
    List<SubPekerjaan> newListSubPekerjaan = [];
    final pekerjaanResponse = ApiService().getPekerjaan(idUser);
    pekerjaanResponse.then((value) => value.data.forEach((element) {
          final subPekerjaanResponse =
              ApiService().getRejectPekerjaan(element.id);
          subPekerjaanResponse
              .then((value) => newListSubPekerjaan.addAll(value.data));
        }));
    if (jabatan == 'atasan') {
      final penggunaResponse = ApiService().getPenggunaStaff(idPosition);
      penggunaResponse.then((value) {
        value.data.forEach((element) {
          ApiService()
              .getSubmitPekerjaanByIdPengguna(element.id)
              .then((value) => {newListSubPekerjaan.addAll(value.data)});
        });
      });
    }
    _counter = newListSubPekerjaan.length;
    _listSubPekerjaan = newListSubPekerjaan;
    notifyListeners();
  }

  addListStaff(int idPosition) {
    _listPengguna.clear();
    final penggunaResponse = ApiService().getPenggunaStaff(idPosition);
    penggunaResponse.then((value) => _listPengguna.addAll(value.data));
    notifyListeners();
  }

  onChange() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final jabatan = sharedPreferences.getString("jabatan")!;
    final idUser = sharedPreferences.getInt("id_user")!;
    final idPosition = sharedPreferences.getInt("position_id")!;
    addListStaff(idPosition);
    addListSubPekerjaan(jabatan, idUser, idPosition);
    notifyListeners();
  }
}
