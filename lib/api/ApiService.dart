import 'dart:convert';

import 'package:daily_log/model/CityResponse.dart';
import 'package:daily_log/model/DurasiHarianResponse.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:daily_log/model/Presence.dart';
import 'package:daily_log/model/PresenceResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.43.126:8000/api";

  var client = http.Client();

  Future<Pengguna> login(Pengguna pengguna) async {
    final response = await client.post(Uri.parse("$baseUrl/pengguna/login"),
        headers: {"content-type": "application/json"},
        body: penggunaToJson(pengguna));
    var data = jsonDecode(response.body);
    print(data['data']);
    return Pengguna.fromJson(data['data']);
  }

  Future<PekerjaanResponse> getPekerjaan(int idUser) async {
    // DateTime now = DateTime.now();
    // DateTime threeDayTomorrow = now.subtract(Duration(days: 10));
    // DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    // String dateTo = dateFormat.format(now);
    // String dateFrom = dateFormat.format(threeDayTomorrow);

    final response =
        await client.get((Uri.parse("$baseUrl/pekerjaan/pengguna/$idUser")));
    var data = jsonDecode(response.body);
    return PekerjaanResponse.fromJson(data);
  }

  Future<void> submitSubPekerjaan(SubPekerjaan subPekerjaan) async {
    final response = await client.post(Uri.parse("$baseUrl/subpekerjaan/store"),
        headers: {"content-type": "application/json"},
        body: subPekerjaanToJson(subPekerjaan));
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<SubPekerjaanResponse> getSubmitPekerjaan(int idPekerjaan) async {
    final response = await client
        .get((Uri.parse("$baseUrl/pengguna/$idPekerjaan/subpekerjaan/submit")));
    var data = jsonDecode(response.body);
    print(data);
    return SubPekerjaanResponse.fromJson(data);
  }

  Future<SubPekerjaanResponse> getRejectPekerjaan(int idUser) async {
    final response = await client
        .get((Uri.parse("$baseUrl/pengguna/$idUser/subpekerjaan/reject")));
    var data = jsonDecode(response.body);
    print(data);
    return SubPekerjaanResponse.fromJson(data);
  }

  Future<bool> updateSubPekerjaan(SubPekerjaan subPekerjaan) async {
    final response = await client.post(
        Uri.parse("$baseUrl/subpekerjaan/update"),
        headers: {"content-type": "application/json"},
        body: subPekerjaanToJson(subPekerjaan));
    var data = jsonDecode(response.body);
    print(data);
    return data['data'];
  }

  Future<void> deleteSubPekerjaan(int idSubpekerjaan) async {
    final response =
        await client.delete(Uri.parse("$baseUrl/subpekerjaan/$idSubpekerjaan"));
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<PenggunaResponse> getPenggunaStaff(int idPosition) async {
    final response = await client
        .get((Uri.parse("$baseUrl/pengguna/$idPosition/list/staff")));
    var data = jsonDecode(response.body);
    print(data);
    return PenggunaResponse.fromJson(data);
  }

  Future<SubPekerjaanResponse> getSubmitPekerjaanByIdPengguna(
      int idUser) async {
    final response = await client.get(
        (Uri.parse("$baseUrl/pengguna/$idUser/pekerjaan/subpekerjaan/submit")));
    var data = jsonDecode(response.body);
    print(data);
    return SubPekerjaanResponse.fromJson(data);
  }

  Future<int> getValidPekerjaanCount(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/pengguna/$idUser/subpekerjaan/$dateFrom/$dateTo/valid/count")));
    var data = jsonDecode(response.body);
    print(data['data']);
    return data['data'];
  }

  Future<SubPekerjaanResponse> getValidPekerjaan(int idPekerjaan) async {
    final response = await client
        .get((Uri.parse("$baseUrl/pengguna/$idPekerjaan/subpekerjaan/valid")));
    var data = jsonDecode(response.body);
    print(data);
    return SubPekerjaanResponse.fromJson(data);
  }

  Future<DurasiHarianResponse> getDurasiHarian(
      int id, String dateFrom, String dateTo) async {
    final response = await client.get(
        (Uri.parse("$baseUrl/chart/pengguna/$id/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<PekerjaanResponse> getPekerjaanSatuBulan(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/pekerjaan/pengguna/$idUser/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return PekerjaanResponse.fromJson(data);
  }

  Future<PositionResponse> getPosition() async {
    final response = await client.get((Uri.parse("$baseUrl/position")));
    var data = jsonDecode(response.body);
    return PositionResponse.fromJson(data);
  }

  Future<PresenceResponse> getTodayPresence(int idUser, String date) async {
    final response =
        await client.get((Uri.parse("$baseUrl/presence/$idUser/$date")));
    var data = jsonDecode(response.body);
    print(data);
    return PresenceResponse.fromJson(data);
  }

  Future<bool> updatePresence(Presence presence) async {
    final response = await client.post(Uri.parse("$baseUrl/presence/update"),
        headers: {"content-type": "application/json"},
        body: presenceToJson(presence));
    var data = jsonDecode(response.body);
    print(data);
    return data['data'];
  }

  Future<void> submitPresence(Presence presence) async {
    final response = await client.post(Uri.parse("$baseUrl/presence/store"),
        headers: {"content-type": "application/json"},
        body: presenceToJson(presence));
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<CityResponse> getCity() async {
    final response = await client.get((Uri.parse("$baseUrl/city")));
    var data = jsonDecode(response.body);
    return CityResponse.fromJson(data);
  }

  Future<Pengguna> getPenggunaByPosition(int idPosition) async {
    final response =
        await client.get(Uri.parse("$baseUrl/pengguna/position/$idPosition"));
    var data = jsonDecode(response.body);
    print(data['data']);
    return Pengguna.fromJson(data['data']);
  }

  Future<DurasiHarianResponse> getDurasiHarianTim(
      int idPosition, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/chart/tim/$idPosition/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<void> checkInQRCode(
      String username, double latitude, double longitude) async {
    final response = await client.get(
        (Uri.parse("$baseUrl/arrival/checkin/$username/$latitude/$longitude")));
  }

  Future<void> checkOutQRCode(
      String username, double latitude, double longitude) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/arrival/checkout/$username/$latitude/$longitude")));
  }
}
