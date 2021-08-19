import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class LaporanKinerjaAtasanPage extends StatelessWidget {
  final int idUser;
  const LaporanKinerjaAtasanPage({Key? key, required this.idUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Laporan Kinerja"),
            bottom: TabBar(tabs: [
              Tab(
                text: "PERSONAL",
              ),
              Tab(
                text: "TIM",
              )
            ]),
            actions: [
              IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
            ],
          ),
          body: TabBarView(children: [
            LaporanKinerjaPersonal(idUser: this.idUser),
            LaporanKinerjaTim()
          ]),
          bottomSheet: MenuBottom(),
        ));
  }
}

class LaporanKinerjaPersonal extends StatefulWidget {
  final int idUser;
  const LaporanKinerjaPersonal({Key? key, required this.idUser})
      : super(key: key);

  @override
  _LaporanKinerjaPersonalState createState() => _LaporanKinerjaPersonalState();
}

class _LaporanKinerjaPersonalState extends State<LaporanKinerjaPersonal> {
  late Future<PekerjaanResponse> pekerjaanResponse;
  int totalPekerjaan = 0;
  List<DurasiHarian> listDurasiHarian = [];
  String dropdownValue = '';
  var now = new DateTime.now();
  List<String> listBulanDropdown = [];
  List<String> listBulan = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    loadDataTotalPekerjaan();

    String thisMonth = DateFormat("MMMM yyyy").format(now);
    dropdownValue = thisMonth;
    loadDurasiHarianPerBulan(thisMonth);
    loadPekeraanSatuBulan(thisMonth);

    listBulan.forEach((element) {
      listBulanDropdown.add(element + " " + now.year.toString());
    });
  }

  loadDataTotalPekerjaan() async {
    int count = await ApiService().getValidPekerjaanCount(widget.idUser);
    setState(() {
      totalPekerjaan = count;
    });
  }

  loadPekeraanSatuBulan(String date) {
    var selectedMonth = DateFormat("MMMM yyyy").parse(date);
    // Find the last day of the month.
    var lastDayDateTime = (selectedMonth.month < 12)
        ? new DateTime(selectedMonth.year, selectedMonth.month + 1, 0)
        : new DateTime(selectedMonth.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM").format(lastDayDateTime);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);

    pekerjaanResponse =
        ApiService().getPekerjaanSatuBulan(widget.idUser, firstDate, endDate);
  }

  loadDurasiHarianPerBulan(String date) async {
    var selectedMonth = DateFormat("MMMM yyyy").parse(date);
    // Find the last day of the month.
    var lastDayDateTime = (selectedMonth.month < 12)
        ? new DateTime(selectedMonth.year, selectedMonth.month + 1, 0)
        : new DateTime(selectedMonth.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM").format(lastDayDateTime);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);

    var durasiResponse =
        await ApiService().getDurasiHarian("$firstDate-01", endDate);
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
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: Color(0xFF5A9EFF),
                  borderRadius: BorderRadius.circular(8)),
              child: DropdownButton<String>(
                isExpanded: true,
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                iconEnabledColor: Colors.white,
                elevation: 16,
                underline: SizedBox(),
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    loadDurasiHarianPerBulan(dropdownValue);
                    loadPekeraanSatuBulan(dropdownValue);
                  });
                  print(dropdownValue);
                },
                items: listBulanDropdown
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Container(
                height: 200,
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
                    "$totalPekerjaan",
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
            Text("Daftar Pekerjaan"),
            FutureBuilder<PekerjaanResponse>(
                future: pekerjaanResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error");
                  } else if (snapshot.hasData) {
                    List<Pekerjaan> items = snapshot.data!.data;
                    if (items.length > 0) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ListPekerjaanValid(
                              pekerjaan: items[index],
                            );
                          });
                    } else {
                      return Center(child: Text("No Data"));
                    }
                  }

                  return CircularProgressIndicator();
                })
          ],
        ),
      ),
    );
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

class ListPekerjaanValid extends StatefulWidget {
  final Pekerjaan pekerjaan;
  const ListPekerjaanValid({Key? key, required this.pekerjaan})
      : super(key: key);

  @override
  _ListPekerjaanValidState createState() => _ListPekerjaanValidState();
}

class _ListPekerjaanValidState extends State<ListPekerjaanValid> {
  late Future<SubPekerjaanResponse> subPekerjaanResponse;
  int durasi = 0;

  @override
  void initState() {
    super.initState();
    subPekerjaanResponse = ApiService().getValidPekerjaan(widget.pekerjaan.id);
    setTotalDurasi();
  }

  setTotalDurasi() async {
    await subPekerjaanResponse.then((value) => (value.data.forEach((element) {
          setState(() {
            durasi = durasi + element.durasi;
          });
        })));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(this.widget.pekerjaan.nama),
              Text(this.widget.pekerjaan.tanggal),
              Text("Durasi: 0$durasi:00"),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 0,
                endIndent: 0,
              ),
              FutureBuilder<SubPekerjaanResponse>(
                  future: subPekerjaanResponse,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error");
                    } else if (snapshot.hasData) {
                      List<SubPekerjaan> items = snapshot.data!.data;
                      if (items.length > 0) {
                        return ListView.builder(
                            itemCount: items.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(items[index].nama),
                                    Text("Durasi: 0${items[index].durasi}:00"),
                                    const Divider(
                                      height: 20,
                                      thickness: 2,
                                      indent: 0,
                                      endIndent: 0,
                                    ),
                                  ],
                                ),
                              );
                            });
                      } else {
                        return Center(
                          child: Text("No Data"),
                        );
                      }
                    }
                    return CircularProgressIndicator();
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class LaporanKinerjaTim extends StatelessWidget {
  const LaporanKinerjaTim({Key? key}) : super(key: key);

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
                child: SimpleTimeSeriesChartTim(
                    SimpleTimeSeriesChartTim._createSampleData())),
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
                    "100",
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
                        DropDownFilterTim()
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text("Tanggal"),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8),
                                  fillColor: Color(0xFFE3F5FF),
                                  filled: true,
                                  hintText: " ",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
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
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8),
                                  fillColor: Color(0xFFE3F5FF),
                                  filled: true,
                                  hintText: " ",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text("Unit Kerja"),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8),
                                  fillColor: Color(0xFFE3F5FF),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    MaterialButton(
                      onPressed: () => {},
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
            ListTeam()
          ],
        ),
      ),
    );
  }
}

class DropDownFilterTim extends StatefulWidget {
  const DropDownFilterTim({Key? key}) : super(key: key);

  @override
  _DropDownFilterTimState createState() => _DropDownFilterTimState();
}

class _DropDownFilterTimState extends State<DropDownFilterTim> {
  String dropdownValue = '1 Hari';

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
          items: <String>['1 Hari', '1 Minggu', '1 Bulan', 'By Calendar']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ListTeam extends StatelessWidget {
  const ListTeam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ItemListTim(),
          ItemListTim(),
          ItemListTim(),
          ItemListTim(),
          ItemListTim()
        ],
      ),
    );
  }
}

class ItemListTim extends StatelessWidget {
  const ItemListTim({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(flex: 1, child: CircleAvatar()),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("Staff 1"), Text("Jabatan")],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  alignment: Alignment.center,
                  width: 24,
                  height: 24,
                  color: Colors.blue,
                  child: Text(
                    "2",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SimpleTimeSeriesChartTim extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate = false;

  SimpleTimeSeriesChartTim(this.seriesList);

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChartTim.withSampleData() {
    return new SimpleTimeSeriesChartTim(
      _createSampleData(),
      // Disable animations for image tests.
    );
  }

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

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
