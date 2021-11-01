import 'dart:developer';

import 'package:daily_log/BebanKerjaPage.dart';
import 'package:daily_log/KehadiranPage.dart';
import 'package:daily_log/LaporanKinerjaPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Kehadiran.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/Position.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;

class DashboardPage extends StatelessWidget {
  final int idUser;
  final int idPosition;
  const DashboardPage(
      {Key? key, required this.idUser, required this.idPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Dashboard"),
            bottom: TabBar(tabs: [
              Tab(
                text: "TIM",
              ),
              Tab(
                text: "KEHADIRAN",
              ),
              Tab(
                text: "BEBAN KERJA",
              ),
            ]),
            actions: [NotificationWidget()],
          ),
          body: TabBarView(children: [
            LaporanKinerjaTim(
              idPosition: this.idPosition,
            ),
            DashboardKehadiran(
              idPosition: this.idPosition,
            ),
            BebanKerjaTim(
              idPosition: this.idPosition,
            )
          ]),
          bottomSheet: MenuBottom(),
        ));
  }
}

class LaporanKinerjaTim extends StatefulWidget {
  final int idPosition;
  const LaporanKinerjaTim({Key? key, required this.idPosition})
      : super(key: key);

  @override
  _LaporanKinerjaTimState createState() => _LaporanKinerjaTimState();
}

class _LaporanKinerjaTimState extends State<LaporanKinerjaTim> {
  String dropdownValue = '1 Bulan';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isOneDay = false;

  List<DurasiHarian> listDurasiHarian = [];

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, 1);
    var lastDayDateTime = (now.month < 12)
        ? new DateTime(now.year, now.month + 1, 0)
        : new DateTime(now.year + 1, 1, 0);
    loadDataTotalPekerjaan(
        dateFormat.format(firstDate), dateFormat.format(lastDayDateTime));
    loadDurasiHarianTim(
        dateFormat.format(firstDate), dateFormat.format(lastDayDateTime));
  }

  loadDataTotalPekerjaan(String firstDate, String endDate) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    int idPosition = sharedPreferences.getInt("position_id")!;

    int count = 0;
    PenggunaResponse penggunaResponse =
        await ApiService().getPenggunaStaff(idPosition);
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
    listDurasiHarian.clear();
    if (firstDate == endDate) {
      isOneDay = true;
      var durasiResponse = await ApiService()
          .getDurasiHarianTim1Hari(widget.idPosition, firstDate, endDate);
      setState(() {
        listDurasiHarian = durasiResponse.data;
      });
    } else {
      isOneDay = false;
      var durasiResponse = await ApiService()
          .getDurasiHarianTim(widget.idPosition, firstDate, endDate);
      setState(() {
        listDurasiHarian = durasiResponse.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    height: 150,
                    width: double.infinity,
                    child: LineChartTotalPekerjaan(
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
                    "Total Pekerjaan",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Periode"),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                color: Color(0xFFE3F5FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black)),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 16,
                              iconEnabledColor: Colors.black,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: <String>[
                                '1 Hari',
                                '1 Minggu',
                                '1 Bulan',
                                'By Calendar'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (dropdownValue == "By Calendar")
                      Row(
                        children: [
                          Text("Tanggal"),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  pickDateRange(context);
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: _fromDateController,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 8),
                                      fillColor: Color(0xFFE3F5FF),
                                      filled: true,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text("to"),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  pickDateRange(context);
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: _untilDateController,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 8),
                                      fillColor: Color(0xFFE3F5FF),
                                      filled: true,
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    MaterialButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
                        switch (dropdownValue) {
                          case '1 Hari':
                            print(dateFormat.format(now));
                            String date = dateFormat.format(now);
                            setState(() {
                              loadDurasiHarianTim(date, date);
                              loadDataTotalPekerjaan(date, date);
                            });
                            break;
                          case '1 Minggu':
                            String endDate = dateFormat.format(now);
                            String firstDate = dateFormat
                                .format(now.subtract(Duration(days: 6)));
                            print(firstDate);
                            print(endDate);
                            setState(() {
                              loadDurasiHarianTim(firstDate, endDate);
                              loadDataTotalPekerjaan(firstDate, endDate);
                            });
                            break;
                          case '1 Bulan':
                            DateTime firstDate =
                                DateTime(now.year, now.month, 1);
                            var lastDayDateTime = (now.month < 12)
                                ? new DateTime(now.year, now.month + 1, 0)
                                : new DateTime(now.year + 1, 1, 0);
                            print(dateFormat.format(firstDate));
                            print(dateFormat.format(lastDayDateTime));
                            setState(() {
                              loadDurasiHarianTim(dateFormat.format(firstDate),
                                  dateFormat.format(lastDayDateTime));
                              loadDataTotalPekerjaan(
                                  dateFormat.format(firstDate),
                                  dateFormat.format(lastDayDateTime));
                            });
                            break;
                          default:
                            print(dateFormat.format(dateTimeRange!.start));
                            print(dateFormat.format(dateTimeRange!.end));
                            String firstDate =
                                dateFormat.format(dateTimeRange!.start);
                            String endDate =
                                dateFormat.format(dateTimeRange!.end);
                            setState(() {
                              loadDurasiHarianTim(firstDate, endDate);
                              loadDataTotalPekerjaan(firstDate, endDate);
                            });
                            break;
                        }
                      },
                      height: 48,
                      minWidth: 96,
                      color: Colors.blue,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "TAMPILKAN",
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListTeam(
              tab: "tim",
              idPosition: widget.idPosition,
            )
          ],
        ),
      ),
    );
  }

  Future pickDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 24 * 2)));
    final newDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: dateTimeRange ?? initialDateRange);

    if (newDateRange == null) {
      return;
    } else {
      setState(() {
        dateTimeRange = newDateRange;
        _untilDateController.text = getUntilDate();
        _fromDateController.text = getFromDate();
      });
    }
  }

  String getFromDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.start);
    }
  }

  String getUntilDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.end);
    }
  }
}

class ListTeam extends StatefulWidget {
  final String tab;
  final int idPosition;
  const ListTeam({Key? key, required this.tab, required this.idPosition})
      : super(key: key);

  @override
  _ListTeamState createState() => _ListTeamState();
}

class _ListTeamState extends State<ListTeam> {
  late Future<PositionResponse> positionResponse;

  @override
  void initState() {
    positionResponse = ApiService().getPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<PositionResponse>(
      future: positionResponse,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("No Data"),
          );
        } else if (snapshot.hasData) {
          List<Position> items = snapshot.data!.data;
          var listStaf = items
              .where((element) => element.parentId == widget.idPosition)
              .toList();
          var filteredList =
              items.where((element) => element.level > 1).toList();
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: listStaf.length,
              itemBuilder: (context, index) {
                return ItemListTim(
                    position: listStaf[index],
                    listPosition: filteredList,
                    tab: widget.tab);
              });
        }

        return CircularProgressIndicator();
      },
    ));
  }
}

class ItemListTim extends StatefulWidget {
  final Position position;
  final List<Position> listPosition;
  final String tab;
  const ItemListTim(
      {Key? key,
      required this.position,
      required this.listPosition,
      required this.tab})
      : super(key: key);

  @override
  _ItemListTimState createState() => _ItemListTimState();
}

class _ItemListTimState extends State<ItemListTim> {
  bool isExpanded = false;
  bool isAtasan = true;
  late List<Position> filteredList;
  late List<Position> listStaf;

  @override
  void initState() {
    filteredList = widget.listPosition
        .where((element) => element.level > widget.position.level)
        .toList();
    listStaf = filteredList
        .where((element) => element.parentId == widget.position.id)
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            child: ListTile(
          onTap: () async {
            Pengguna pengguna =
                await ApiService().getPenggunaByPosition(widget.position.id);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return widget.tab == "tim"
                  ? LaporanKinerjaPage(idUser: pengguna.id)
                  : widget.tab == "beban kerja"
                      ? BebanKerjaPage(idUser: pengguna.id)
                      : KehadiranPage(idUser: pengguna.id);
            }));
          },
          leading: CircleAvatar(),
          title: Text(widget.position.position),
          subtitle: Text(widget.position.position),
          trailing: listStaf.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: isExpanded
                      ? Icon(Icons.keyboard_arrow_up)
                      : Icon(Icons.keyboard_arrow_down),
                )
              : SizedBox(),
        )),
        if (isExpanded)
          Container(
            padding: EdgeInsets.only(left: 10),
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: listStaf.length,
                itemBuilder: (context, index) {
                  return ItemListTim(
                    position: listStaf[index],
                    listPosition: filteredList,
                    tab: widget.tab,
                  );
                }),
          )
      ],
    );
  }
}

class DashboardKehadiran extends StatefulWidget {
  final int idPosition;
  const DashboardKehadiran({Key? key, required this.idPosition})
      : super(key: key);

  @override
  _DashboardKehadiranState createState() => _DashboardKehadiranState();
}

class _DashboardKehadiranState extends State<DashboardKehadiran> {
  String dropdownValue = '1 Bulan';
  String selectedFilter = '1 Bulan';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isOneDay = false;

  List<Kehadiran> listKehadiran = [];

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, 1);
    var lastDayDateTime = (now.month < 12)
        ? new DateTime(now.year, now.month + 1, 0)
        : new DateTime(now.year + 1, 1, 0);

    loadKehadiranTim(
        dateFormat.format(firstDate), dateFormat.format(lastDayDateTime));
  }

  loadKehadiranTim(String firstDate, String endDate) async {
    firstDate == endDate ? isOneDay = true : isOneDay = false;
    var durasiResponse = await ApiService()
        .getKehadiranTim(widget.idPosition, firstDate, endDate);
    setState(() {
      listKehadiran = durasiResponse.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            SizedBox(
              height: 8,
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Periode"),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                color: Color(0xFFE3F5FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black)),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 16,
                              iconEnabledColor: Colors.black,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: <String>[
                                '1 Hari',
                                '1 Minggu',
                                '1 Bulan',
                                'By Calendar'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (dropdownValue == "By Calendar")
                      Row(
                        children: [
                          Text("Tanggal"),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  pickDateRange(context);
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: _fromDateController,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 8),
                                      fillColor: Color(0xFFE3F5FF),
                                      filled: true,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text("to"),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  pickDateRange(context);
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: _untilDateController,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 8),
                                      fillColor: Color(0xFFE3F5FF),
                                      filled: true,
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    MaterialButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
                        switch (dropdownValue) {
                          case '1 Hari':
                            print(dateFormat.format(now));
                            String date = dateFormat.format(now);
                            setState(() {
                              selectedFilter = dropdownValue;
                              loadKehadiranTim(date, date);
                            });
                            break;
                          case '1 Minggu':
                            DateTime firstDayofWeek =
                                now.subtract(Duration(days: now.weekday - 1));
                            DateTime lastDateofWeek =
                                firstDayofWeek.add(Duration(days: 6));
                            print(dateFormat.format(firstDayofWeek));
                            print(dateFormat.format(lastDateofWeek));
                            String firstDate =
                                dateFormat.format(firstDayofWeek);
                            String endDate = dateFormat.format(lastDateofWeek);
                            setState(() {
                              selectedFilter = dropdownValue;
                              loadKehadiranTim(firstDate, endDate);
                            });
                            break;
                          case '1 Bulan':
                            DateTime firstDate =
                                DateTime(now.year, now.month, 1);
                            var lastDayDateTime = (now.month < 12)
                                ? new DateTime(now.year, now.month + 1, 0)
                                : new DateTime(now.year + 1, 1, 0);
                            print(dateFormat.format(firstDate));
                            print(dateFormat.format(lastDayDateTime));
                            setState(() {
                              selectedFilter = dropdownValue;
                              loadKehadiranTim(dateFormat.format(firstDate),
                                  dateFormat.format(lastDayDateTime));
                            });
                            break;
                          default:
                            print(dateFormat.format(dateTimeRange!.start));
                            print(dateFormat.format(dateTimeRange!.end));
                            String firstDate =
                                dateFormat.format(dateTimeRange!.start);
                            String endDate =
                                dateFormat.format(dateTimeRange!.end);
                            setState(() {
                              selectedFilter = dropdownValue;
                              loadKehadiranTim(firstDate, endDate);
                            });
                            break;
                        }
                      },
                      height: 48,
                      minWidth: 96,
                      color: Colors.blue,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "TAMPILKAN",
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListTeam(
              tab: "kehadiran",
              idPosition: widget.idPosition,
            )
          ],
        ),
      ),
    );
  }

  Future pickDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 24 * 2)));
    final newDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: dateTimeRange ?? initialDateRange);

    if (newDateRange == null) {
      return;
    } else {
      setState(() {
        dateTimeRange = newDateRange;
        _untilDateController.text = getUntilDate();
        _fromDateController.text = getFromDate();
      });
    }
  }

  String getFromDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.start);
    }
  }

  String getUntilDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.end);
    }
  }
}

class OrdinalSales {
  final DateTime year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class BebanKerjaTim extends StatefulWidget {
  final int idPosition;
  const BebanKerjaTim({Key? key, required this.idPosition}) : super(key: key);

  @override
  _BebanKerjaTimState createState() => _BebanKerjaTimState();
}

class _BebanKerjaTimState extends State<BebanKerjaTim> {
  String dropdownValue = '1 Bulan';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isOneDay = false;

  List<DurasiHarian> listDurasiHarian = [];

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, 1);
    var lastDayDateTime = (now.month < 12)
        ? new DateTime(now.year, now.month + 1, 0)
        : new DateTime(now.year + 1, 1, 0);
    loadDataTotalPekerjaan(
        dateFormat.format(firstDate), dateFormat.format(lastDayDateTime));
    loadDurasiHarianTim(
        dateFormat.format(firstDate), dateFormat.format(lastDayDateTime));
  }

  loadDataTotalPekerjaan(String firstDate, String endDate) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    int idPosition = sharedPreferences.getInt("position_id")!;

    int count = 0;
    PenggunaResponse penggunaResponse =
        await ApiService().getPenggunaStaff(idPosition);
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
      var durasiResponse = await ApiService()
          .getDurasiHarianTim1Hari(widget.idPosition, firstDate, endDate);
      setState(() {
        listDurasiHarian.clear();
        List<DurasiHarian> listDurasiTemp = durasiResponse.data;
        listDurasiTemp.forEach((element) {
          element.durasi = element.durasi * 100 ~/ 480;
          log(element.durasi.toString());
          listDurasiHarian.add(element);
        });
      });
    } else {
      isOneDay = false;
      var durasiResponse = await ApiService()
          .getDurasiHarianTim(widget.idPosition, firstDate, endDate);
      setState(() {
        listDurasiHarian.clear();
        List<DurasiHarian> listDurasiTemp = durasiResponse.data;
        listDurasiTemp.forEach((element) {
          element.durasi = element.durasi * 100 ~/ 480;
          log(element.durasi.toString());
          listDurasiHarian.add(element);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    height: 150,
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
            Card(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Periode"),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                color: Color(0xFFE3F5FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black)),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 16,
                              iconEnabledColor: Colors.black,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: <String>[
                                '1 Hari',
                                '1 Minggu',
                                '1 Bulan',
                                'By Calendar'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (dropdownValue == "By Calendar")
                      Row(
                        children: [
                          Text("Tanggal"),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  pickDateRange(context);
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: _fromDateController,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 8),
                                      fillColor: Color(0xFFE3F5FF),
                                      filled: true,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text("to"),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  pickDateRange(context);
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: _untilDateController,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 8),
                                      fillColor: Color(0xFFE3F5FF),
                                      filled: true,
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    MaterialButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
                        switch (dropdownValue) {
                          case '1 Hari':
                            print(dateFormat.format(now));
                            String date = dateFormat.format(now);
                            setState(() {
                              loadDurasiHarianTim(date, date);
                              loadDataTotalPekerjaan(date, date);
                            });
                            break;
                          case '1 Minggu':
                            String endDate = dateFormat.format(now);
                            String firstDate = dateFormat
                                .format(now.subtract(Duration(days: 6)));
                            setState(() {
                              loadDurasiHarianTim(firstDate, endDate);
                              loadDataTotalPekerjaan(firstDate, endDate);
                            });
                            break;
                          case '1 Bulan':
                            DateTime firstDate =
                                DateTime(now.year, now.month, 1);
                            var lastDayDateTime = (now.month < 12)
                                ? new DateTime(now.year, now.month + 1, 0)
                                : new DateTime(now.year + 1, 1, 0);
                            print(dateFormat.format(firstDate));
                            print(dateFormat.format(lastDayDateTime));
                            setState(() {
                              loadDurasiHarianTim(dateFormat.format(firstDate),
                                  dateFormat.format(lastDayDateTime));
                              loadDataTotalPekerjaan(
                                  dateFormat.format(firstDate),
                                  dateFormat.format(lastDayDateTime));
                            });
                            break;
                          default:
                            print(dateFormat.format(dateTimeRange!.start));
                            print(dateFormat.format(dateTimeRange!.end));
                            String firstDate =
                                dateFormat.format(dateTimeRange!.start);
                            String endDate =
                                dateFormat.format(dateTimeRange!.end);
                            setState(() {
                              loadDurasiHarianTim(firstDate, endDate);
                              loadDataTotalPekerjaan(firstDate, endDate);
                            });
                            break;
                        }
                      },
                      height: 48,
                      minWidth: 96,
                      color: Colors.blue,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "TAMPILKAN",
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListTeam(
              tab: "beban kerja",
              idPosition: widget.idPosition,
            )
          ],
        ),
      ),
    );
  }

  Future pickDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 24 * 2)));
    final newDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: dateTimeRange ?? initialDateRange);

    if (newDateRange == null) {
      return;
    } else {
      setState(() {
        dateTimeRange = newDateRange;
        _untilDateController.text = getUntilDate();
        _fromDateController.text = getFromDate();
      });
    }
  }

  String getFromDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.start);
    }
  }

  String getUntilDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.end);
    }
  }
}

class LineChartKehadiran extends StatelessWidget {
  final List<Kehadiran> listKehadiran;
  const LineChartKehadiran({Key? key, required this.listKehadiran})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<OrdinalSales> hadirData = [];
    List<OrdinalSales> tidakHadirData = [];

    listKehadiran.forEach((element) {
      hadirData.add(new OrdinalSales(element.tanggal, element.hadir));
      tidakHadirData.add(new OrdinalSales(element.tanggal, element.tidakHadir));
    });
    return chart.SfCartesianChart(
        tooltipBehavior: chart.TooltipBehavior(enable: true),
        legend: chart.Legend(
            isVisible: true, position: chart.LegendPosition.bottom),
        primaryXAxis: chart.DateTimeAxis(),
        series: <chart.ChartSeries>[
          // Renders line chart
          chart.LineSeries<OrdinalSales, DateTime>(
              name: 'Hadir',
              dataSource: hadirData,
              xValueMapper: (OrdinalSales sales, _) => sales.year,
              yValueMapper: (OrdinalSales sales, _) => sales.sales),
          chart.LineSeries<OrdinalSales, DateTime>(
              name: 'Tidak hadir',
              dataSource: tidakHadirData,
              xValueMapper: (OrdinalSales sales, _) => sales.year,
              yValueMapper: (OrdinalSales sales, _) => sales.sales)
        ]);
  }
}

class LineChartBebanKerja extends StatefulWidget {
  final List<DurasiHarian> listData;
  final bool isOneDay;
  const LineChartBebanKerja(
      {Key? key, required this.listData, this.isOneDay = false})
      : super(key: key);

  @override
  _LineChartBebanKerjaState createState() => _LineChartBebanKerjaState();
}

class _LineChartBebanKerjaState extends State<LineChartBebanKerja> {
  late chart.TooltipBehavior _tooltipBehavior;
  @override
  void initState() {
    _tooltipBehavior =
        chart.TooltipBehavior(enable: true, format: 'point.x : point.y%');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return chart.SfCartesianChart(
        tooltipBehavior: _tooltipBehavior,
        primaryXAxis: chart.DateTimeAxis(
            edgeLabelPlacement: chart.EdgeLabelPlacement.shift,
            intervalType: widget.isOneDay
                ? chart.DateTimeIntervalType.hours
                : chart.DateTimeIntervalType.days),
        series: <chart.ChartSeries>[
          // Renders line chart
          chart.LineSeries<DurasiHarian, DateTime>(
              name: 'Beban Kerja',
              enableTooltip: true,
              dataSource: widget.listData,
              xValueMapper: (DurasiHarian durasiHarian, _) =>
                  durasiHarian.tanggal,
              yValueMapper: (DurasiHarian durasiHarian, _) =>
                  durasiHarian.durasi)
        ]);
  }
}

class LineChartTotalPekerjaan extends StatefulWidget {
  final List<DurasiHarian> listData;
  final bool isOneDay;
  const LineChartTotalPekerjaan(
      {Key? key, required this.listData, this.isOneDay = false})
      : super(key: key);

  @override
  _LineChartTotalPekerjaanState createState() =>
      _LineChartTotalPekerjaanState();
}

class _LineChartTotalPekerjaanState extends State<LineChartTotalPekerjaan> {
  late chart.TooltipBehavior _tooltipBehavior;
  @override
  void initState() {
    _tooltipBehavior = chart.TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return chart.SfCartesianChart(
        axisLabelFormatter: (chart.AxisLabelRenderDetails args) {
          String text = args.text;
          if (args.axisName == 'primaryYAxis') {
            int value = args.value.toInt();
            if (value < 60) {
              if (value >= 10) {
                text = '00:${args.text}';
              } else {
                text = '00:0${args.text}';
              }
            } else {
              int jam = value ~/ 60;
              int menit = value % 60;
              if (jam < 10) {
                if (menit < 10 && menit > 0) {
                  text = '0$jam:0$menit';
                } else if (menit >= 10) {
                  text = '0$jam:$menit';
                } else {
                  text = '0$jam:00';
                }
              } else {
                if (menit < 10 && menit > 0) {
                  text = '$jam:0$menit';
                } else if (menit >= 10) {
                  text = '$jam:$menit';
                } else {
                  text = '$jam:00';
                }
              }
            }
          }

          return chart.ChartAxisLabel(text, args.textStyle);
        },
        onTooltipRender: (args) {
          List<dynamic>? chartdata = args.dataPoints;
          args.header = DateFormat('d MMM yyyy')
              .format(chartdata![args.pointIndex!.toInt()].x);
          int value = chartdata[args.pointIndex!.toInt()].y;
          if (value < 60) {
            if (value >= 10) {
              args.text = '00:$value';
            } else {
              args.text = '00:0$value';
            }
          } else {
            int jam = value ~/ 60;
            int menit = value % 60;
            if (jam < 10) {
              if (menit < 10 && menit > 0) {
                args.text = '0$jam:0$menit';
              } else if (menit >= 10) {
                args.text = '0$jam:$menit';
              } else {
                args.text = '0$jam:00';
              }
            } else {
              if (menit < 10 && menit > 0) {
                args.text = '$jam:0$menit';
              } else if (menit >= 10) {
                args.text = '$jam:$menit';
              } else {
                args.text = '$jam:00';
              }
            }
          }
        },
        tooltipBehavior: _tooltipBehavior,
        primaryXAxis: chart.DateTimeAxis(
            edgeLabelPlacement: chart.EdgeLabelPlacement.shift,
            intervalType: widget.isOneDay
                ? chart.DateTimeIntervalType.hours
                : chart.DateTimeIntervalType.days),
        series: <chart.ChartSeries>[
          // Renders line chart
          chart.LineSeries<DurasiHarian, DateTime>(
              name: 'Total durasi pekerjaan',
              enableTooltip: true,
              dataSource: widget.listData,
              xValueMapper: (DurasiHarian durasiHarian, _) =>
                  durasiHarian.tanggal,
              yValueMapper: (DurasiHarian durasiHarian, _) =>
                  durasiHarian.durasi)
        ]);
  }
}

class ColumnChartKehadiran extends StatelessWidget {
  final List<Kehadiran> listKehadiran;
  const ColumnChartKehadiran({Key? key, required this.listKehadiran})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chart.SfCartesianChart(
        tooltipBehavior: chart.TooltipBehavior(enable: true, format: 'point.y'),
        legend: chart.Legend(
            isVisible: true, position: chart.LegendPosition.bottom),
        primaryXAxis:
            chart.DateTimeAxis(intervalType: chart.DateTimeIntervalType.days),
        series: <chart.ChartSeries>[
          // Renders line chart
          chart.ColumnSeries<Kehadiran, DateTime>(
              name: 'Hadir',
              dataSource: listKehadiran,
              xValueMapper: (Kehadiran kehadiran, _) => kehadiran.tanggal,
              yValueMapper: (Kehadiran kehadiran, _) => kehadiran.hadir),
          chart.ColumnSeries<Kehadiran, DateTime>(
              name: 'Tidak hadir',
              dataSource: listKehadiran,
              xValueMapper: (Kehadiran kehadiran, _) => kehadiran.tanggal,
              yValueMapper: (Kehadiran kehadiran, _) => kehadiran.tidakHadir)
        ]);
  }
}
