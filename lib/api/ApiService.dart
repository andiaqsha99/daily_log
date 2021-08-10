import 'dart:convert';

import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/Pengguna.dart';
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
}
