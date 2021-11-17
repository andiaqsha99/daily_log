import 'package:daily_log/DashboardPage.dart';
import 'package:daily_log/KinerjaTimStaffPage.dart' as timStaff;
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Kehadiran.dart';
import 'package:flutter/material.dart';

class KehadiranTimStaffPage extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final String idPosition;
  final int idStaff;
  const KehadiranTimStaffPage(
      {Key? key,
      required this.firstDate,
      required this.lastDate,
      required this.idPosition,
      required this.idStaff})
      : super(key: key);

  @override
  _KehadiranTimStaffPageState createState() => _KehadiranTimStaffPageState();
}

class _KehadiranTimStaffPageState extends State<KehadiranTimStaffPage> {
  int totalPekerjaan = 0;
  bool isOneDay = false;

  List<Kehadiran> listKehadiran = [];

  @override
  void initState() {
    super.initState();
    loadKehadiranTim(widget.firstDate, widget.lastDate);
  }

  loadKehadiranTim(String firstDate, String endDate) async {
    firstDate == endDate ? isOneDay = true : isOneDay = false;
    var durasiResponse = await ApiService()
        .getKehadiranTimStaff(widget.idStaff, firstDate, endDate);
    setState(() {
      listKehadiran = durasiResponse.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kehadiran Tim"),
        actions: [NotificationWidget()],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 56),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              listKehadiran.length == 0
                  ? Center(child: Text("Tidak ada data"))
                  : Container(
                      height: 200,
                      width: double.infinity,
                      child: isOneDay
                          ? ColumnChartKehadiran(listKehadiran: listKehadiran)
                          : LineChartKehadiran(listKehadiran: listKehadiran)),
              SizedBox(
                height: 8,
              ),
              timStaff.ListTeam(
                tab: "kehadiran",
                idUser: widget.idStaff,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: MenuBottom(),
    );
  }
}
