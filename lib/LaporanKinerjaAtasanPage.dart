import 'package:daily_log/MenuBottom.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class LaporanKinerjaAtasanPage extends StatelessWidget {
  const LaporanKinerjaAtasanPage({Key? key}) : super(key: key);

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
          body: TabBarView(
              children: [LaporanKinerjaPersonal(), LaporanKinerjaTim()]),
          bottomSheet: MenuBottom(),
        ));
  }
}

class LaporanKinerjaPersonal extends StatelessWidget {
  const LaporanKinerjaPersonal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 56),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropDownFilter(),
            Container(
                height: 150,
                width: double.infinity,
                child: SimpleTimeSeriesChart(
                    SimpleTimeSeriesChart._createSampleData())),
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
            Text("Daftar Pekerjaan"),
            ListPekerjaanValid(),
            ListPekerjaanValid()
          ],
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
                child: SimpleTimeSeriesChart(
                    SimpleTimeSeriesChart._createSampleData())),
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

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate = false;

  SimpleTimeSeriesChart(this.seriesList);

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withSampleData() {
    return new SimpleTimeSeriesChart(
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

class ListPekerjaanValid extends StatelessWidget {
  const ListPekerjaanValid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var items = List<String>.generate(2, (index) => "$index");
    return Container(
      child: Card(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama Pekerjaan"),
              Text("21/07/2021"),
              Text("Durasi: 01:00"),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 0,
                endIndent: 0,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Detail Pekerjaan"),
                    Text("Durasi: 01:00"),
                    const Divider(
                      height: 20,
                      thickness: 2,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Detail Pekerjaan"),
                    Text("Durasi: 01:00"),
                    const Divider(
                      height: 20,
                      thickness: 2,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownFilter extends StatefulWidget {
  const DropDownFilter({Key? key}) : super(key: key);

  @override
  _DropDownFilterState createState() => _DropDownFilterState();
}

class _DropDownFilterState extends State<DropDownFilter> {
  String dropdownValue = 'Juli 2021';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Color(0xFF5A9EFF), borderRadius: BorderRadius.circular(8)),
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
          });
        },
        items: <String>[
          'Juli 2021',
          'Agustus 2021',
          'Septtember 2021',
          'November 2021'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
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
