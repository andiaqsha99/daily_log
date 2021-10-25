import 'package:daily_log/DashboardPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:flutter/material.dart';
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
              SizedBox(
                height: 8,
              ),
              totalPekerjaan == 0
                  ? Center(child: Text("Tidak ada data"))
                  : Column(
                      children: [
                        Container(
                            height: 200,
                            width: double.infinity,
                            child: LineChartTotalPekerjaan(
                              listData: listDurasiHarian,
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
                                      physics: NeverScrollableScrollPhysics(),
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
  int jam = 0;
  int menit = 0;

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
    setState(() {
      jam = durasi ~/ 60;
      menit = durasi % 60;
    });
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
              Text(
                  menit > 9 ? "Durasi: 0$jam:$menit" : "Durasi: 0$jam:0$menit"),
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
                            physics: NeverScrollableScrollPhysics(),
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
                                    Text(items[index].durasi < 10
                                        ? "Durasi: 00:0${items[index].durasi}"
                                        : "Durasi: 00:${items[index].durasi}"),
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
