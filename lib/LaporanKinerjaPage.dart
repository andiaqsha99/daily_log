import 'package:daily_log/DashboardPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/LaporanKinerja.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PersetujuanPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

import 'model/LaporanKinerjaResponse.dart';

class LaporanKinerjaPage extends StatefulWidget {
  final int idUser;
  final String? firstDate;
  final String? lastDate;
  const LaporanKinerjaPage(
      {Key? key, required this.idUser, this.firstDate, this.lastDate})
      : super(key: key);

  @override
  _LaporanKinerjaPageState createState() => _LaporanKinerjaPageState();
}

class _LaporanKinerjaPageState extends State<LaporanKinerjaPage> {
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
    print("total pekerjaan $firstDate $endDate");
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
    if (_firstDate != '-' && _lastDate != '-') {
      firstDate = widget.firstDate!;
      endDate = widget.lastDate!;
    }
    print("pekerjaan $firstDate $endDate");
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
    print("durasi harian $firstDate $endDate");
    var durasiResponse =
        await ApiService().getDurasiHarian(widget.idUser, firstDate, endDate);
    setState(() {
      listDurasiHarian = durasiResponse.data;
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
            ? Text("Laporan Kinerja")
            : _pengguna!.nip == "000000"
                ? Text("Laporan Kinerja")
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
                            child: LineChartTotalPekerjaan(
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

class ListPekerjaanValid extends StatefulWidget {
  final PersetujuanPekerjaan pekerjaan;
  const ListPekerjaanValid({Key? key, required this.pekerjaan})
      : super(key: key);

  @override
  _ListPekerjaanValidState createState() => _ListPekerjaanValidState();
}

class _ListPekerjaanValidState extends State<ListPekerjaanValid> {
  late List<SubPekerjaan> listSubpekerjaan;
  int durasi = 0;
  int jam = 0;
  int menit = 0;

  @override
  void initState() {
    super.initState();
    listSubpekerjaan = widget.pekerjaan.subPekerjaan;
    setTotalDurasi();
  }

  setTotalDurasi() async {
    listSubpekerjaan.forEach((element) {
      setState(() {
        durasi = durasi + element.durasi;
      });
    });
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
              Text(
                this.widget.pekerjaan.nama,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 4,
              ),
              Text(menit > 9
                  ? jam > 9
                      ? "Durasi: $jam:$menit"
                      : "Durasi: 0$jam:$menit"
                  : jam > 9
                      ? "Durasi: $jam:0$menit"
                      : "Durasi: 0$jam:0$menit"),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 0,
                endIndent: 0,
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: listSubpekerjaan.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listSubpekerjaan[index].nama,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text("Tanggal: " +
                              DateFormat("dd-MM-yyyy").format(DateTime.parse(
                                  listSubpekerjaan[index].tanggal))),
                          SizedBox(
                            height: 4,
                          ),
                          Text((() {
                            if (listSubpekerjaan[index].durasi < 10) {
                              return "Durasi: 00:0${listSubpekerjaan[index].durasi}";
                            } else if (listSubpekerjaan[index].durasi > 59) {
                              int jam = listSubpekerjaan[index].durasi ~/ 60;
                              int menit = listSubpekerjaan[index].durasi % 60;
                              if (menit < 10) {
                                return "Durasi: 0$jam:0$menit";
                              }
                              return "Durasi: $jam:$menit";
                            } else {
                              return "Durasi: 00:${listSubpekerjaan[index].durasi}";
                            }
                          }())),
                          const Divider(
                            height: 20,
                            thickness: 2,
                            indent: 0,
                            endIndent: 0,
                          ),
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class ListLaporanKinerja extends StatefulWidget {
  final LaporanKinerjaResponse laporanKinerjaResponse;
  const ListLaporanKinerja({Key? key, required this.laporanKinerjaResponse})
      : super(key: key);

  @override
  _ListLaporanKinerjaState createState() => _ListLaporanKinerjaState();
}

class _ListLaporanKinerjaState extends State<ListLaporanKinerja> {
  late List<LaporanKinerja> listSubpekerjaan;
  int durasi = 0;
  int jam = 0;
  int menit = 0;

  @override
  void initState() {
    super.initState();
    listSubpekerjaan = widget.laporanKinerjaResponse.listLaporanKinerja;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat("dd MMMM yyyy")
              .format(DateTime.parse(widget.laporanKinerjaResponse.tanggal)),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Card(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupedListView<LaporanKinerja, String>(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  elements: widget.laporanKinerjaResponse.listLaporanKinerja,
                  groupBy: (element) {
                    return element.namaPekerjaan;
                  },
                  groupSeparatorBuilder: (groupBy) {
                    return Text(
                      groupBy,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                  itemBuilder: (context, element) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            element.nama,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text((() {
                            if (element.durasi < 10) {
                              return "Durasi: 00:0${element.durasi}";
                            } else if (element.durasi > 59) {
                              int jam = element.durasi ~/ 60;
                              int menit = element.durasi % 60;
                              if (menit < 10) {
                                return "Durasi: 0$jam:0$menit";
                              }
                              return "Durasi: $jam:$menit";
                            } else {
                              return "Durasi: 00:${element.durasi}";
                            }
                          }())),
                          const Divider(
                            height: 20,
                            thickness: 2,
                            indent: 0,
                            endIndent: 0,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
