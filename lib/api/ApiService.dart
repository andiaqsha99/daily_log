import 'dart:convert';

import 'package:daily_log/model/DurasiHarianResponse.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:8000/api";

  var client = http.Client();

  Future<Pengguna> login(Pengguna pengguna) async {
    final response = await client.post(Uri.parse("$baseUrl/pengguna/login"),
        headers: {"content-type": "application/json"},
        body: penggunaToJson(pengguna));
    var data = jsonDecode(response.body);
    print(data['data']);
    return Pengguna.fromJson(data['data']);
  }

  Future<PekerjaanResponse> getPekerjaan(int id) async {
    final response =
        await client.get((Uri.parse("$baseUrl/pekerjaan/pengguna/$id")));
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

  Future<PenggunaResponse> getPenggunaStaff() async {
    final response =
        await client.get((Uri.parse("$baseUrl/pengguna/list/staff")));
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

  Future<int> getValidPekerjaanCount(int idUser) async {
    final response = await client
        .get((Uri.parse("$baseUrl/pengguna/$idUser/subpekerjaan/valid/count")));
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
      String dateFrom, String dateTo) async {
    final response =
        await client.get((Uri.parse("$baseUrl/tanggal/$dateFrom/$dateTo")));
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
}
