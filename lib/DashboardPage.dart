import 'dart:developer';

import 'package:daily_log/BebanKerjaPage.dart';
import 'package:daily_log/LaporanKinerjaPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Kehadiran.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/Position.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate = false;

  SimpleTimeSeriesChart(this.seriesList);

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  static List<charts.Series<DurasiHarian, DateTime>> _createSampleData(
      List<DurasiHarian> data) {
    return [
      new charts.Series<DurasiHarian, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DurasiHarian durasiHarian, _) => durasiHarian.tanggal,
        measureFn: (DurasiHarian durasiHarian, _) => durasiHarian.durasi,
        data: data,
      )
    ];
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
  String dropdownValue = '1 Hari';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;

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
    var durasiResponse = await ApiService()
        .getDurasiHarianTim(widget.idPosition, firstDate, endDate);
    setState(() {
      listDurasiHarian = durasiResponse.data;
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
            Container(
                height: 150,
                width: double.infinity,
                child: SimpleTimeSeriesChart(
                    SimpleTimeSeriesChart._createSampleData(listDurasiHarian))),
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
  const ListTeam({Key? key, required this.tab}) : super(key: key);

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
          var listStaf =
              items.where((element) => element.parentId == 1).toList();
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
                  : BebanKerjaPage(idUser: pengguna.id);
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
  String dropdownValue = '1 Hari';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;

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
    loadDataTotalPekerjaan(
        dateFormat.format(firstDate), dateFormat.format(lastDayDateTime));
    loadKehadiranTim(
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

  loadKehadiranTim(String firstDate, String endDate) async {
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
            Container(
                height: 150,
                width: double.infinity,
                child: GroupedBarChart(
                    GroupedBarChart._createSampleData(listKehadiran),
                    animate: false)),
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
                              loadKehadiranTim(date, date);
                              loadDataTotalPekerjaan(date, date);
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
                              loadKehadiranTim(firstDate, endDate);
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
                              loadKehadiranTim(dateFormat.format(firstDate),
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
                              loadKehadiranTim(firstDate, endDate);
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
              tab: "kehadiran",
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

class GroupedBarChart extends StatelessWidget {
  final List<charts.Series<OrdinalSales, String>> seriesList;
  final bool animate;

  GroupedBarChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData(
      List<Kehadiran> listData) {
    List<OrdinalSales> desktopSalesData = [];
    List<OrdinalSales> tableSalesData = [];

    listData.forEach((element) {
      desktopSalesData.add(new OrdinalSales(element.tanggal, element.hadir));
      tableSalesData.add(new OrdinalSales(element.tanggal, element.tidakHadir));
    });

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableSalesData,
      )
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
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
  String dropdownValue = '1 Hari';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;

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
    var durasiResponse = await ApiService()
        .getDurasiHarianTim(widget.idPosition, firstDate, endDate);
    setState(() {
      List<DurasiHarian> listDurasiTemp = durasiResponse.data;
      listDurasiTemp.forEach((element) {
        element.durasi = element.durasi * 100 ~/ 480;
        log(element.durasi.toString());
        listDurasiHarian.add(element);
      });
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
            Container(
                height: 150,
                width: double.infinity,
                child: SimpleTimeSeriesChart(
                    SimpleTimeSeriesChart._createSampleData(listDurasiHarian))),
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
            ListTeam(tab: "beban kerja")
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
