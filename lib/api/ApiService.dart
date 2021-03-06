import 'dart:convert';

import 'package:daily_log/model/CityResponse.dart';
import 'package:daily_log/model/DurasiHarianResponse.dart';
import 'package:daily_log/model/KehadiranResponse.dart';
import 'package:daily_log/model/LaporanKinerjaResponse.dart';
import 'package:daily_log/model/NotifResponse.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/Pengumuman.dart';
import 'package:daily_log/model/PengumumanResponse.dart';
import 'package:daily_log/model/PersetujuanResponse.dart';
import 'package:daily_log/model/PieChartDataResponse.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:daily_log/model/Presence.dart';
import 'package:daily_log/model/PresenceResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:daily_log/model/Users.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  final String baseUrl = "https://hurryup.universitaspertamina.ac.id/daily/api";
  final String storageUrl =
      "https://hurryup.universitaspertamina.ac.id/daily/storage/";
  // final String baseUrl = "http://192.168.45.253:8000/api";
  // final String storageUrl = "http://192.168.45.253:8000/storage/";

  var client = http.Client();

  Future<PenggunaResponse> login(Pengguna pengguna) async {
    final response = await client.post(Uri.parse("$baseUrl/pengguna/login"),
        headers: {"content-type": "application/json"},
        body: penggunaToJson(pengguna));
    var data = jsonDecode(response.body);
    print(data);
    return PenggunaResponse.fromJson(data);
  }

  Future<PekerjaanResponse> getPekerjaan(int idUser) async {
    final response =
        await client.get((Uri.parse("$baseUrl/pekerjaan/pengguna/$idUser")));
    var data = jsonDecode(response.body);
    return PekerjaanResponse.fromJson(data);
  }

  Future<SubPekerjaan> submitSubPekerjaan(SubPekerjaan subPekerjaan) async {
    final response = await client.post(Uri.parse("$baseUrl/subpekerjaan/store"),
        headers: {"content-type": "application/json"},
        body: subPekerjaanToJson(subPekerjaan));
    print(response.body);
    var data = jsonDecode(response.body);
    print(data);
    return SubPekerjaan.fromJson(data['data']);
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

  Future<PenggunaResponse> getPenggunaStaff(int idUser) async {
    final response =
        await client.get((Uri.parse("$baseUrl/pengguna/$idUser/list/staff")));
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

  Future<PersetujuanResponse> getPekerjaanSatuBulan(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/pengguna/$idUser/persetujuan/subpekerjaan/valid/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return PersetujuanResponse.fromJson(data);
  }

  Future<PositionResponse> getPosition() async {
    // final response = await client.get((Uri.parse("$baseUrl/position")));
    final response = await client.get((Uri.parse(
        "https://hurryup.universitaspertamina.ac.id/api/positions")));
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

  Future<DurasiHarianResponse> getDurasiHarianTim(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client.get(
        (Uri.parse("$baseUrl/chart/tim/$idUser/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<DurasiHarianResponse> getDurasiHarianTim1Hari(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/chart/tim/$idUser/tanggal/$dateFrom/$dateTo/hari")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<void> checkInQRCode(
      String username, double latitude, double longitude) async {
    await client.get(
        (Uri.parse("$baseUrl/arrival/checkin/$username/$latitude/$longitude")));
  }

  Future<void> checkOutQRCode(String username) async {
    await client.get((Uri.parse("$baseUrl/arrival/checkout/$username")));
  }

  Future<PersetujuanResponse> getSubmitPersetujuan(int idUser) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/pengguna/$idUser/persetujuan/subpekerjaan/submit")));
    var data = jsonDecode(response.body);
    print(data);
    return PersetujuanResponse.fromJson(data);
  }

  Future<PersetujuanResponse> getRejectPersetujuan(int idUser) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/pengguna/$idUser/persetujuan/subpekerjaan/reject")));
    var data = jsonDecode(response.body);
    return PersetujuanResponse.fromJson(data);
  }

  Future<KehadiranResponse> getKehadiranTim(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client
        .get((Uri.parse("$baseUrl/presence/tim/$idUser/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return KehadiranResponse.fromJson(data);
  }

  Future<NotifResponse> getListNotification(int idUser) async {
    final response =
        await client.get((Uri.parse("$baseUrl/notification/pengguna/$idUser")));
    var data = jsonDecode(response.body);
    print(data);
    return NotifResponse.fromJson(data);
  }

  Future<void> updateNotificationRead(int idNotif) async {
    final response =
        await client.get((Uri.parse("$baseUrl/notification/$idNotif/read")));
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<void> createRejectNotif(int idReceiver, int idSubPekerjaan) async {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String date = dateFormat.format(now);

    final response = await client.post(Uri.parse("$baseUrl/notification/store"),
        headers: {"content-type": "application/json"},
        body: jsonEncode({
          'receiver_id': idReceiver,
          'subpekerjaan_id': idSubPekerjaan,
          'is_read': 0,
          'date': date,
          'status': "reject"
        }));
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<void> createSubmitNotif(
      int idReceiver, int idSubPekerjaan, int idSender) async {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String date = dateFormat.format(now);

    print("$idReceiver, $idSubPekerjaan, $idSender");

    final response = await client.post(Uri.parse("$baseUrl/notification/store"),
        headers: {"content-type": "application/json"},
        body: jsonEncode({
          'receiver_id': idReceiver,
          'subpekerjaan_id': idSubPekerjaan,
          'sender': idSender,
          'is_read': 0,
          'date': date,
          'status': "submit"
        }));
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<Pengguna> getPenggunaById(int idPengguna) async {
    final response =
        await client.get(Uri.parse("$baseUrl/pengguna/$idPengguna"));
    var data = jsonDecode(response.body);
    print(data['data']);
    return Pengguna.fromJson(data['data']);
  }

  Future<int> getUnreadNotification(int idUser) async {
    final response = await client
        .get((Uri.parse("$baseUrl/notification/pengguna/$idUser/count")));
    var data = jsonDecode(response.body);
    print(data);
    return data['data'];
  }

  Future<PresenceResponse> getUserPresenceByDate(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client
        .get((Uri.parse("$baseUrl/presence/list/$idUser/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return PresenceResponse.fromJson(data);
  }

  Future<DurasiHarianResponse> getDurasiHarianTimStaff(
      String idPosition, int idStaff, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/chart/tim/$idPosition/$idStaff/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<DurasiHarianResponse> getDurasiHarianTimStaff1Hari(
      String idPosition, int idStaff, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/chart/tim/$idPosition/$idStaff/tanggal/$dateFrom/$dateTo/hari")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<KehadiranResponse> getKehadiranTimStaff(
      int idUser, String dateFrom, String dateTo) async {
    final response = await client.get(
        (Uri.parse("$baseUrl/presence/tim/staff/$idUser/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return KehadiranResponse.fromJson(data);
  }

  Future<String> uploadFoto(String idUser, String path) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse("$baseUrl/pengguna/foto/upload"));
    request.fields['id'] = idUser;
    var image = await http.MultipartFile.fromPath('foto', path);
    request.files.add(image);
    await request.send();

    final response =
        await client.get(Uri.parse("$baseUrl/pengguna/foto/$idUser"));
    var data = jsonDecode(response.body);
    return data['data'];
  }

  Future<List<Users>> getListUsers() async {
    final response =
        await client.get(Uri.parse("http://36.37.91.71:21800/api/User"));
    var data = jsonDecode(response.body);
    return List<Users>.from(data['data'].map((user) {
      return Users.fromJson(user);
    }));
  }

  Future<int> getBackdate() async {
    final response = await client.get((Uri.parse("$baseUrl/setting")));
    var data = jsonDecode(response.body);
    print(data);
    return data['data'];
  }

  Future<SubPekerjaan> getSubpekerjaanById(int idSubpekerjaan) async {
    final response =
        await client.get((Uri.parse("$baseUrl/subpekerjaan/$idSubpekerjaan")));
    var data = jsonDecode(response.body);
    print(data);
    return SubPekerjaan.fromJson(data['data']);
  }

  Future<DurasiHarianResponse> getDurasiHarianAllTimStaff(
      int idStaff, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/chart/tim/all/$idStaff/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<DurasiHarianResponse> getDurasiHarianAllTimStaff1Hari(
      int idStaff, String dateFrom, String dateTo) async {
    final response = await client.get((Uri.parse(
        "$baseUrl/chart/tim/all/$idStaff/tanggal/$dateFrom/$dateTo/hari")));
    var data = jsonDecode(response.body);
    print(data);
    return DurasiHarianResponse.fromJson(data);
  }

  Future<void> submitPekerjaan(Pekerjaan pekerjaan) async {
    final response = await client.post(Uri.parse("$baseUrl/pekerjaan/store"),
        headers: {"content-type": "application/json"},
        body: pekerjaanToJson(pekerjaan));
    print(response.body);
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<void> updatePekerjaan(Pekerjaan pekerjaan) async {
    final response = await client.post(Uri.parse("$baseUrl/pekerjaan/update"),
        headers: {"content-type": "application/json"},
        body: pekerjaanToJson(pekerjaan));
    print(response.body);
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<void> deletePekerjaan(int pekerjaanId) async {
    final response =
        await client.delete(Uri.parse("$baseUrl/pekerjaan/$pekerjaanId"));
    print(response.body);
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<PieChartDataResponse> getPieChartData(
      int idStaff, String dateFrom, String dateTo) async {
    final response = await client.get(
        (Uri.parse("$baseUrl/piechart/$idStaff/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    print(data);
    return PieChartDataResponse.fromJson(data);
  }

  Future<List<LaporanKinerjaResponse>> getLaporanKinerjaData(
      int idStaff, String dateFrom, String dateTo) async {
    final response = await client.get(
        (Uri.parse("$baseUrl/kinerja/$idStaff/tanggal/$dateFrom/$dateTo")));
    var data = jsonDecode(response.body);
    return List<LaporanKinerjaResponse>.from(data['data'].map((kinerja) {
      return LaporanKinerjaResponse.fromJson(kinerja);
    }));
  }

  Future<PengumumanResponse> getListPengumuman() async {
    final response = await client.get((Uri.parse("$baseUrl/pengumuman")));
    var data = jsonDecode(response.body);
    print(data);
    return PengumumanResponse.fromJson(data);
  }

  Future<void> submitPengumuman(Pengumuman pengumuman) async {
    final response = await client.post(Uri.parse("$baseUrl/pengumuman/store"),
        headers: {"content-type": "application/json"},
        body: pengumumanToJson(pengumuman));
    print(response.body);
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<void> updatePengumuman(Pengumuman pengumuman) async {
    final response = await client.post(Uri.parse("$baseUrl/pengumuman/update"),
        headers: {"content-type": "application/json"},
        body: pengumumanToJson(pengumuman));
    print(response.body);
    var data = jsonDecode(response.body);
    print(data);
  }

  Future<void> deletePengumuman(int pengumumanId) async {
    final response =
        await client.delete(Uri.parse("$baseUrl/pengumuman/$pengumumanId"));
    print(response.body);
    var data = jsonDecode(response.body);
    print(data);
  }
}
