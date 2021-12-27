import 'dart:developer';

import 'package:daily_log/BebanKerjaPage.dart';
import 'package:daily_log/BebanKerjaTimStaffPage.dart';
import 'package:daily_log/KehadiranPage.dart';
import 'package:daily_log/KehadiranTimStaffPage.dart';
import 'package:daily_log/KinerjaTimStaffPage.dart';
import 'package:daily_log/LaporanKinerjaPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Kehadiran.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/Position.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
            bottom: TabBar(
                labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                tabs: [
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
              idUser: this.idUser,
            ),
            DashboardKehadiran(
              idUser: this.idUser,
            ),
            BebanKerjaTim(
              idUser: this.idUser,
            )
          ]),
          bottomSheet: MenuBottom(),
        ));
  }
}

class LaporanKinerjaTim extends StatefulWidget {
  final int idUser;
  const LaporanKinerjaTim({Key? key, required this.idUser}) : super(key: key);

  @override
  _LaporanKinerjaTimState createState() => _LaporanKinerjaTimState();
}

class _LaporanKinerjaTimState extends State<LaporanKinerjaTim> {
  String dropdownValue = '1 Bulan';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isOneDay = false;
  String _firstDate = '';
  String _lastDate = '';

  List<DurasiHarian> listDurasiHarian = [];

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    String firstDate = dateFormat.format(now.subtract(Duration(days: 30)));
    String lastDate = dateFormat.format(now);
    loadDataTotalPekerjaan(firstDate, lastDate);
    loadDurasiHarianTim(firstDate, lastDate);
  }

  loadDataTotalPekerjaan(String firstDate, String endDate) async {
    _firstDate = firstDate;
    _lastDate = endDate;

    int count = 0;
    PenggunaResponse penggunaResponse =
        await ApiService().getPenggunaStaff(widget.idUser);
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
    _firstDate = firstDate;
    _lastDate = endDate;
    listDurasiHarian.clear();
    if (firstDate == endDate) {
      isOneDay = true;
      var durasiResponse = await ApiService()
          .getDurasiHarianTim1Hari(widget.idUser, firstDate, endDate);
      setState(() {
        listDurasiHarian = durasiResponse.data;
      });
    } else {
      isOneDay = false;
      var durasiResponse = await ApiService()
          .getDurasiHarianTim(widget.idUser, firstDate, endDate);
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
                    height: MediaQuery.of(context).size.height * 0.35,
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
                            String firstDate = dateFormat
                                .format(now.subtract(Duration(days: 30)));
                            String lastDate = dateFormat.format(now);
                            print(firstDate);
                            print(lastDate);
                            setState(() {
                              loadDurasiHarianTim(firstDate, lastDate);
                              loadDataTotalPekerjaan(firstDate, lastDate);
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
              idUser: widget.idUser,
              firstDate: _firstDate,
              lastDate: _lastDate,
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
  final String firstDate;
  final String lastDate;
  final String tab;
  final int idUser;
  const ListTeam(
      {Key? key,
      required this.tab,
      required this.idUser,
      this.firstDate = '',
      this.lastDate = ''})
      : super(key: key);

  @override
  _ListTeamState createState() => _ListTeamState();
}

class _ListTeamState extends State<ListTeam> {
  late Future<PositionResponse> positionResponse;
  late Future<PenggunaResponse> penggunaResponse;
  List<Position> listPosition = [];

  @override
  void initState() {
    loadStaffData();
    loadPositionData();
    super.initState();
  }

  loadPositionData() async {
    positionResponse = ApiService().getPosition();
    positionResponse.then((value) => listPosition = value.data);
  }

  loadStaffData() async {
    penggunaResponse = ApiService().getPenggunaStaff(widget.idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<PenggunaResponse>(
      future: penggunaResponse,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("No Data"),
          );
        } else if (snapshot.hasData) {
          List<Pengguna> items = snapshot.data!.data;
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemListTim(
                    // listPosition: listPosition,
                    pengguna: items[index],
                    tab: widget.tab,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate);
              });
        }

        return CircularProgressIndicator();
      },
    ));
  }
}

class ItemListTim extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final Pengguna pengguna;
  final String tab;
  const ItemListTim(
      {Key? key,
      required this.pengguna,
      required this.tab,
      this.firstDate = '',
      this.lastDate = ''})
      : super(key: key);

  @override
  _ItemListTimState createState() => _ItemListTimState();
}

class _ItemListTimState extends State<ItemListTim> {
  bool isExpanded = false;
  bool isAtasan = true;
  late List<Position> filteredList;
  late Future<PenggunaResponse> penggunaResponse;

  @override
  void initState() {
    loadStaffData();
    super.initState();
  }

  loadStaffData() async {
    penggunaResponse = ApiService().getPenggunaStaff(widget.pengguna.id);
  }

  @override
  Widget build(BuildContext context) {
    var positionProvider = Provider.of<PositionProvider>(context);
    var usersProvider = Provider.of<UsersProvider>(context);
    return Column(
      children: [
        Card(
            child: ListTile(
          onTap: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return widget.tab == "tim"
                  ? LaporanKinerjaPage(
                      idUser: widget.pengguna.id,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                    )
                  : widget.tab == "beban kerja"
                      ? BebanKerjaPage(
                          idUser: widget.pengguna.id,
                          firstDate: widget.firstDate,
                          lastDate: widget.lastDate,
                        )
                      : KehadiranPage(idUser: widget.pengguna.id);
            }));
          },
          leading: widget.pengguna.foto == null
              ? CircleAvatar()
              : CircleAvatar(
                  backgroundImage: NetworkImage(
                      "${ApiService().storageUrl}${widget.pengguna.foto}"),
                ),
          title: widget.pengguna.nip == "000000"
              ? Text(widget.pengguna.username)
              : Text(usersProvider.getUsers(widget.pengguna.nip).name),
          subtitle: widget.pengguna.nip == "000000"
              ? Text(positionProvider
                  .getPosition(widget.pengguna.positionId)
                  .position)
              : Text(usersProvider.getUsers(widget.pengguna.nip).namaJabatan),
          trailing: widget.pengguna.jabatan == "atasan"
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return widget.tab == "tim"
                              ? KinerjaTimStaffPage(
                                  firstDate: widget.firstDate,
                                  lastDate: widget.lastDate,
                                  idPosition:
                                      widget.pengguna.positionId.toString(),
                                  idStaff: widget.pengguna.id)
                              : widget.tab == "beban kerja"
                                  ? BebanKerjaTimStaffPage(
                                      firstDate: widget.firstDate,
                                      lastDate: widget.lastDate,
                                      idPosition:
                                          widget.pengguna.positionId.toString(),
                                      idStaff: widget.pengguna.id)
                                  : KehadiranTimStaffPage(
                                      firstDate: widget.firstDate,
                                      lastDate: widget.lastDate,
                                      idPosition:
                                          widget.pengguna.positionId.toString(),
                                      idStaff: widget.pengguna.id);
                        }));
                      },
                      child: Icon(Icons.group),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: isExpanded
                          ? Icon(Icons.keyboard_arrow_up)
                          : Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                )
              : SizedBox(),
        )),
        if (isExpanded)
          Container(
              padding: EdgeInsets.only(left: 10),
              child: FutureBuilder<PenggunaResponse>(
                future: penggunaResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("No Data"),
                    );
                  } else if (snapshot.hasData) {
                    List<Pengguna> items = snapshot.data!.data;
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ItemListTim(
                              pengguna: items[index],
                              tab: widget.tab,
                              firstDate: widget.firstDate,
                              lastDate: widget.lastDate);
                        });
                  }

                  return CircularProgressIndicator();
                },
              ))
      ],
    );
  }
}

class DashboardKehadiran extends StatefulWidget {
  final int idUser;
  const DashboardKehadiran({Key? key, required this.idUser}) : super(key: key);

  @override
  _DashboardKehadiranState createState() => _DashboardKehadiranState();
}

class _DashboardKehadiranState extends State<DashboardKehadiran> {
  String dropdownValue = '1 Bulan';
  String selectedFilter = '1 Bulan';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isOneDay = false;
  String _firstDate = '';
  String _lastDate = '';

  List<Kehadiran> listKehadiran = [];

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    String firstDate = dateFormat.format(now.subtract(Duration(days: 30)));
    String lastDate = dateFormat.format(now);

    loadKehadiranTim(firstDate, lastDate);
  }

  loadKehadiranTim(String firstDate, String endDate) async {
    _firstDate = firstDate;
    _lastDate = endDate;
    firstDate == endDate ? isOneDay = true : isOneDay = false;
    var durasiResponse =
        await ApiService().getKehadiranTim(widget.idUser, firstDate, endDate);
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
                    height: MediaQuery.of(context).size.height * 0.30,
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
                            String firstDate = dateFormat
                                .format(now.subtract(Duration(days: 30)));
                            String lastDate = dateFormat.format(now);
                            print(firstDate);
                            print(lastDate);
                            setState(() {
                              selectedFilter = dropdownValue;
                              loadKehadiranTim(firstDate, lastDate);
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
              idUser: widget.idUser,
              firstDate: _firstDate,
              lastDate: _lastDate,
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
  final int idUser;
  const BebanKerjaTim({Key? key, required this.idUser}) : super(key: key);

  @override
  _BebanKerjaTimState createState() => _BebanKerjaTimState();
}

class _BebanKerjaTimState extends State<BebanKerjaTim> {
  String dropdownValue = '1 Bulan';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isOneDay = false;
  String _firstDate = '';
  String _lastDate = '';

  List<DurasiHarian> listDurasiHarian = [];

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    String firstDate = dateFormat.format(now.subtract(Duration(days: 30)));
    String lastDate = dateFormat.format(now);
    loadDataTotalPekerjaan(firstDate, lastDate);
    loadDurasiHarianTim(firstDate, lastDate);
  }

  loadDataTotalPekerjaan(String firstDate, String endDate) async {
    _firstDate = firstDate;
    _lastDate = endDate;
    int count = 0;
    PenggunaResponse penggunaResponse =
        await ApiService().getPenggunaStaff(widget.idUser);
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
    _firstDate = firstDate;
    _lastDate = endDate;
    if (firstDate == endDate) {
      isOneDay = true;
      var durasiResponse = await ApiService()
          .getDurasiHarianTim1Hari(widget.idUser, firstDate, endDate);
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
          .getDurasiHarianTim(widget.idUser, firstDate, endDate);
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
                    height: MediaQuery.of(context).size.height * 0.35,
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
                            String firstDate = dateFormat
                                .format(now.subtract(Duration(days: 30)));
                            String lastDate = dateFormat.format(now);
                            print(firstDate);
                            print(lastDate);
                            setState(() {
                              loadDurasiHarianTim(firstDate, lastDate);
                              loadDataTotalPekerjaan(firstDate, lastDate);
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
              idUser: widget.idUser,
              firstDate: _firstDate,
              lastDate: _lastDate,
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
        legend: chart.Legend(
            isVisible: true, position: chart.LegendPosition.bottom),
        primaryXAxis: chart.DateTimeAxis(
            edgeLabelPlacement: chart.EdgeLabelPlacement.shift,
            intervalType: widget.isOneDay
                ? chart.DateTimeIntervalType.hours
                : chart.DateTimeIntervalType.days),
        series: <chart.ChartSeries>[
          // Renders line chart
          chart.LineSeries<DurasiHarian, DateTime>(
              name: 'Total beban kerja & tanggal',
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
        legend: chart.Legend(
            isVisible: true, position: chart.LegendPosition.bottom),
        primaryYAxis: chart.NumericAxis(interval: 60.0),
        primaryXAxis: chart.DateTimeAxis(
            edgeLabelPlacement: chart.EdgeLabelPlacement.shift,
            intervalType: widget.isOneDay
                ? chart.DateTimeIntervalType.hours
                : chart.DateTimeIntervalType.days),
        series: <chart.ChartSeries>[
          // Renders line chart
          chart.LineSeries<DurasiHarian, DateTime>(
              name: 'Total jam pekerjaan & tanggal',
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
