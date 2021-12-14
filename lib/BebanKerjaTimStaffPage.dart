import 'package:daily_log/DashboardPage.dart';
import 'package:daily_log/KinerjaTimStaffPage.dart' as timStaff;
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:flutter/material.dart';
import 'api/ApiService.dart';
import 'model/Pengguna.dart';

class BebanKerjaTimStaffPage extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final String idPosition;
  final int idStaff;
  const BebanKerjaTimStaffPage(
      {Key? key,
      required this.firstDate,
      required this.lastDate,
      required this.idPosition,
      required this.idStaff})
      : super(key: key);

  @override
  _BebanKerjaTimStaffPageState createState() => _BebanKerjaTimStaffPageState();
}

class _BebanKerjaTimStaffPageState extends State<BebanKerjaTimStaffPage> {
  int totalPekerjaan = 0;
  bool isOneDay = false;

  List<DurasiHarian> listDurasiHarian = [];

  @override
  void initState() {
    super.initState();
    loadDataTotalPekerjaan(widget.firstDate, widget.lastDate);
    loadDurasiHarianTim(widget.firstDate, widget.lastDate);
  }

  loadDataTotalPekerjaan(String firstDate, String endDate) async {
    int count = 0;
    int counter = await ApiService()
        .getValidPekerjaanCount(widget.idStaff, firstDate, endDate);
    count += counter;
    PenggunaResponse penggunaResponse =
        await ApiService().getPenggunaStaff(widget.idStaff);
    List<Pengguna> listStaff = penggunaResponse.data;
    listStaff.forEach((element) async {
      int counter = await ApiService()
          .getValidPekerjaanCount(element.id, firstDate, endDate);
      count += counter;
      setState(() {
        totalPekerjaan = count;
      });
    });
  }

  loadDurasiHarianTim(String firstDate, String endDate) async {
    if (firstDate == endDate) {
      isOneDay = true;
      var durasiResponse = await ApiService().getDurasiHarianTimStaff1Hari(
          widget.idPosition, widget.idStaff, firstDate, endDate);
      print(durasiResponse.data);
      setState(() {
        listDurasiHarian = durasiResponse.data;
        listDurasiHarian.forEach((element) {
          element.durasi = element.durasi * 100 ~/ 480;
        });
      });
    } else {
      isOneDay = false;
      var durasiResponse = await ApiService().getDurasiHarianTimStaff(
          widget.idPosition, widget.idStaff, firstDate, endDate);
      setState(() {
        listDurasiHarian = durasiResponse.data;
        listDurasiHarian.forEach((element) {
          element.durasi = element.durasi * 100 ~/ 480;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Beban Kerja Tim"),
        actions: [NotificationWidget()],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 56),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              totalPekerjaan == 0
                  ? Center(
                      child: Text("Tidak ada data"),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      width: double.infinity,
                      child: LineChartBebanKerja(
                        listData: listDurasiHarian,
                        isOneDay: isOneDay,
                      )),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalPekerjaan.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Total Beban Kerja",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              timStaff.ListTeam(
                  tab: "beban kerja",
                  idUser: widget.idStaff,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate)
            ],
          ),
        ),
      ),
      bottomNavigationBar: MenuBottom(),
    );
  }
}
