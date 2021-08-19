import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  @override
  void initState() {
    super.initState();
    pekerjaanResponse = ApiService().getPekerjaan(widget.idUser);
    loadDataTotalPekerjaan();
    loadDurasiHarian();
  }

  loadDataTotalPekerjaan() async {
    int count = await ApiService().getValidPekerjaanCount(widget.idUser);
    setState(() {
      totalPekerjaan = count;
    });
  }

  loadDurasiHarian() async {
    var durasiResponse =
        await ApiService().getDurasiHarian("2021-08-01", "2021-08-31");
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
              DropDownFilter(),
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
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ListPekerjaanValid(
                              pekerjaan: items[index],
                            );
                          });
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
