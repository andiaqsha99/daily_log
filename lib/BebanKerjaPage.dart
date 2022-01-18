// ignore_for_file: unused_import

import 'dart:developer';

import 'package:daily_log/DashboardPage.dart';
import 'package:daily_log/LaporanKinerjaPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PersetujuanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

import 'model/LaporanKinerjaResponse.dart';
import 'model/PersetujuanPekerjaan.dart';

class BebanKerjaPage extends StatefulWidget {
  final int idUser;
  final String? firstDate;
  final String? lastDate;
  const BebanKerjaPage(
      {Key? key, required this.idUser, this.firstDate, this.lastDate})
      : super(key: key);

  @override
  _BebanKerjaPageState createState() => _BebanKerjaPageState();
}

class _BebanKerjaPageState extends State<BebanKerjaPage> {
  late Future<List<LaporanKinerjaResponse>> laporanKinerjaResponse;
  int totalPekerjaan = 0;
  List<DurasiHarian> listDurasiHarian = [];
  String selectedDate = '';
  var now = new DateTime.now();
  String? _firstDate = '-';
  String? _lastDate = '-';
  Pengguna? _pengguna;

  @override
  void initState() {
    super.initState();
    setDate();
    String thisMonth = DateFormat("MMMM yyyy").format(now);
    selectedDate = thisMonth;

    DateTime firstDate = DateTime(now.year, now.month, 1);
    loadDurasiHarianPerBulan(firstDate);
    loadDataTotalPekerjaan(firstDate);
    loadPekeraanSatuBulan(firstDate);
    loadDataPengguna();
  }

  setDate() {
    if (widget.firstDate != null) {
      _firstDate = widget.firstDate;
      _lastDate = widget.lastDate;
    }
  }

  loadDataTotalPekerjaan(DateTime date) async {
    var lastDayDateTime = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 0)
        : new DateTime(date.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM-dd").format(date);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);
    if (_firstDate != '-' && _lastDate != '-') {
      firstDate = widget.firstDate!;
      endDate = widget.lastDate!;
    }
    int count = await ApiService()
        .getValidPekerjaanCount(widget.idUser, firstDate, endDate);
    setState(() {
      totalPekerjaan = count;
    });
  }

  loadPekeraanSatuBulan(DateTime date) {
    // Find the last day of the month.
    var lastDayDateTime = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 0)
        : new DateTime(date.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM-dd").format(date);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);
    if (widget.firstDate != null && widget.lastDate != null) {
      firstDate = widget.firstDate!;
      endDate = widget.lastDate!;
    }
    laporanKinerjaResponse =
        ApiService().getLaporanKinerjaData(widget.idUser, firstDate, endDate);
  }

  loadDurasiHarianPerBulan(DateTime date) async {
    // Find the last day of the month.
    var lastDayDateTime = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 0)
        : new DateTime(date.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM-dd").format(date);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);
    if (_firstDate != '-' && _lastDate != '-') {
      firstDate = widget.firstDate!;
      endDate = widget.lastDate!;
    }
    var durasiResponse =
        await ApiService().getDurasiHarian(widget.idUser, firstDate, endDate);
    setState(() {
      List<DurasiHarian> listDurasiTemp = durasiResponse.data;
      listDurasiTemp.forEach((element) {
        element.durasi = element.durasi * 100 ~/ 480;
        log(element.durasi.toString());
        listDurasiHarian.add(element);
      });
    });
  }

  loadDataPengguna() async {
    var pengguna = await ApiService().getPenggunaById(widget.idUser);
    setState(() {
      _pengguna = pengguna;
    });
  }

  @override
  Widget build(BuildContext context) {
    var usersProvider = Provider.of<UsersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: _pengguna == null
            ? Text("Beban Kerja")
            : _pengguna!.nip == "000000"
                ? Text("Beban Kerja")
                : Text(usersProvider.getUsers(_pengguna!.nip).name),
        actions: [NotificationWidget()],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      onPressed: () {
                        showMonthPicker(
                                context: context,
                                initialDate:
                                    DateFormat("MMMM yyyy").parse(selectedDate))
                            .then((date) {
                          if (date != null) {
                            setState(() {
                              _firstDate = '-';
                              _lastDate = '-';
                              print(date);
                              String thisMonth =
                                  DateFormat("MMMM yyyy").format(date);
                              selectedDate = thisMonth;
                              print(selectedDate);
                              loadDurasiHarianPerBulan(date);
                              loadPekeraanSatuBulan(date);
                              loadDataTotalPekerjaan(date);
                            });
                          }
                        });
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          selectedDate,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.black),
                        ),
                      ))),
              SizedBox(
                height: 8,
              ),
              totalPekerjaan == 0
                  ? Center(child: Text("Tidak ada data"))
                  : Column(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.30,
                            width: double.infinity,
                            child: LineChartBebanKerja(
                              listData: listDurasiHarian,
                            )),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$totalPekerjaan",
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                "Total Pekerjaan",
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text("Daftar Pekerjaan"),
                        FutureBuilder<List<LaporanKinerjaResponse>>(
                            future: laporanKinerjaResponse,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("Error");
                              } else if (snapshot.hasData) {
                                List<LaporanKinerjaResponse> items =
                                    snapshot.data!;
                                if (items.length > 0) {
                                  return ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        return ListLaporanKinerja(
                                          laporanKinerjaResponse: items[index],
                                        );
                                      });
                                } else {
                                  return Center(child: Text("No Data"));
                                }
                              }

                              return CircularProgressIndicator();
                            }),
                      ],
                    )
            ],
          ),
        ),
      ),
      bottomNavigationBar: MenuBottom(),
    );
  }
}
