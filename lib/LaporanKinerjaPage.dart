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
import 'package:month_picker_dialog/month_picker_dialog.dart';

class LaporanKinerjaPage extends StatefulWidget {
  final int idUser;
  const LaporanKinerjaPage({Key? key, required this.idUser}) : super(key: key);

  @override
  _LaporanKinerjaPageState createState() => _LaporanKinerjaPageState();
}

class _LaporanKinerjaPageState extends State<LaporanKinerjaPage> {
  late Future<PekerjaanResponse> pekerjaanResponse;
  int totalPekerjaan = 0;
  List<DurasiHarian> listDurasiHarian = [];
  String selectedDate = '';
  var now = new DateTime.now();

  @override
  void initState() {
    super.initState();

    String thisMonth = DateFormat("MMMM yyyy").format(now);
    selectedDate = thisMonth;

    DateTime firstDate = DateTime(now.year, now.month, 1);
    loadDurasiHarianPerBulan(firstDate);
    loadDataTotalPekerjaan(firstDate);
    loadPekeraanSatuBulan(firstDate);
  }

  loadDataTotalPekerjaan(DateTime date) async {
    var lastDayDateTime = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 0)
        : new DateTime(date.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM-dd").format(date);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);
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

    pekerjaanResponse =
        ApiService().getPekerjaanSatuBulan(widget.idUser, firstDate, endDate);
  }

  loadDurasiHarianPerBulan(DateTime date) async {
    // Find the last day of the month.
    var lastDayDateTime = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 0)
        : new DateTime(date.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM-dd").format(date);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);

    var durasiResponse =
        await ApiService().getDurasiHarian(widget.idUser, firstDate, endDate);
    setState(() {
      listDurasiHarian = durasiResponse.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Kinerja"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 56),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                      onPressed: () {
                        showMonthPicker(
                                context: context,
                                initialDate:
                                    DateFormat("MMMM yyyy").parse(selectedDate))
                            .then((date) {
                          if (date != null) {
                            setState(() {
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
                        ),
                      ))),
              Container(
                  height: 200,
                  width: double.infinity,
                  child: SimpleTimeSeriesChart(
                      SimpleTimeSeriesChart._createSampleData(
                          listDurasiHarian))),
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
      ),
      bottomSheet: MenuBottom(),
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
