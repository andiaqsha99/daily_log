import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/NotifProvider.dart';
import 'package:daily_log/model/PersetujuanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/PersetujuanPekerjaan.dart';
import 'model/SettingProvider.dart';

class PersetujuanPage extends StatelessWidget {
  final int intialIndex;
  final int? idSubPekerjaan;
  const PersetujuanPage({Key? key, this.intialIndex = 0, this.idSubPekerjaan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: this.intialIndex,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Persetujuan"),
            bottom: TabBar(tabs: [
              Tab(
                text: "MENUNGGU",
              ),
              Tab(
                text: "DITOLAK",
              )
            ]),
            actions: [NotificationWidget()],
          ),
          body: TabBarView(children: [
            MenungguPage(),
            DitolakPage(
              idSubPekerjaan: this.idSubPekerjaan,
            )
          ]),
          bottomNavigationBar: MenuBottom(),
        ));
  }
}

class MenungguPage extends StatefulWidget {
  const MenungguPage({Key? key}) : super(key: key);

  @override
  _MenungguPageState createState() => _MenungguPageState();
}

class _MenungguPageState extends State<MenungguPage> {
  late Future<PersetujuanResponse> pekerjaanResponse;
  int idUser = 1;

  @override
  void initState() {
    super.initState();
    getLoginData();
    loadPekerjaanData();
  }

  loadPekerjaanData() async {
    pekerjaanResponse = ApiService().getSubmitPersetujuan(idUser);
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idUser = sharedPreferences.getInt("id_user")!;
      loadPekerjaanData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 8,
            ),
            FutureBuilder<PersetujuanResponse>(
                future: pekerjaanResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.data;
                    List<PersetujuanPekerjaan> listPekerjaan = data;
                    if (listPekerjaan.length > 0) {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: listPekerjaan.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listPekerjaan[index].nama,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                PekerjaanMenungguCard(
                                  listSubPekerjaan:
                                      listPekerjaan[index].subPekerjaan,
                                  loadData: getLoginData,
                                )
                              ],
                            );
                          });
                    } else {
                      return Center(
                          child: Text("Tidak ada pekerjaan yang disubmit"));
                    }
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  }
                  return CircularProgressIndicator();
                }),
          ],
        ),
      ),
    );
  }
}

class PekerjaanMenungguCard extends StatefulWidget {
  final List<SubPekerjaan> listSubPekerjaan;
  final Function loadData;
  const PekerjaanMenungguCard(
      {Key? key, required this.listSubPekerjaan, required this.loadData})
      : super(key: key);

  @override
  _PekerjaanMenungguCardState createState() => _PekerjaanMenungguCardState();
}

class _PekerjaanMenungguCardState extends State<PekerjaanMenungguCard> {
  List<SubPekerjaan> items = [];
  List<EditingContoller> listController = [];

  @override
  void initState() {
    items = widget.listSubPekerjaan;
    listController = List<EditingContoller>.generate(
        items.length,
        (index) => EditingContoller(
            nama: TextEditingController(),
            keterangan: TextEditingController(),
            durasi: TextEditingController(),
            tanggal: TextEditingController()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<SettingProvider>(context);
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        listController[index].nama.text = items[index].nama;
        listController[index].durasi.text = items[index].durasi.toString();
        listController[index].tanggal.text = items[index].tanggal;
        return Card(
            child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              items[index].nama,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              items[index].tanggal,
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              (() {
                if (items[index].durasi < 10) {
                  return "Durasi: 00:0${items[index].durasi}";
                } else if (items[index].durasi > 59) {
                  int jam = items[index].durasi ~/ 60;
                  int menit = items[index].durasi % 60;
                  if (menit < 10) {
                    return "Durasi: 0$jam:0$menit";
                  }
                  return "Durasi: $jam:$menit";
                } else {
                  return "Durasi: 00:${items[index].durasi}";
                }
              }()),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                MaterialButton(
                  onPressed: () => {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Edit Pekerjaan'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: TextFormField(
                                controller: listController[index].nama,
                                decoration: InputDecoration(
                                    labelText: "Nama pekerjaan",
                                    hintText: "Nama Pekerjaan",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              child: GestureDetector(
                                onTap: () async {
                                  return await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Container(
                                            height: 200,
                                            width: 300,
                                            child: CupertinoTimerPicker(
                                              onTimerDurationChanged:
                                                  (duration) => {
                                                listController[index]
                                                        .durasi
                                                        .text =
                                                    duration.inMinutes
                                                        .toString()
                                              },
                                              mode: CupertinoTimerPickerMode.hm,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("OK")),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("BATAL"))
                                          ],
                                        );
                                      });
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: listController[index].durasi,
                                  decoration: InputDecoration(
                                      labelText: "Durasi",
                                      hintText: "Durasi",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            GestureDetector(
                              onTap: () async {
                                DateTime itemDate =
                                    DateFormat("yyyy-MM-dd HH:mm:ss").parse(
                                        listController[index].tanggal.text);
                                final date = await showDatePicker(
                                    context: context,
                                    initialDate: itemDate,
                                    lastDate: itemDate,
                                    firstDate: itemDate.subtract(Duration(
                                        days:
                                            settingProvider.numBackDate - 1)));
                                if (date != null) {
                                  String formatTime = DateFormat("HH:mm:ss")
                                      .format(DateTime.now());
                                  String formatDate =
                                      DateFormat("yyyy-MM-dd").format(date);
                                  listController[index].tanggal.text =
                                      "$formatDate $formatTime";
                                }
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: listController[index].tanggal,
                                decoration: InputDecoration(
                                    labelText: "Tanggal",
                                    hintText: "Tanggal",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              var subPekerjaan = items[index];
                              subPekerjaan.nama =
                                  listController[index].nama.text;
                              subPekerjaan.tanggal =
                                  listController[index].tanggal.text;
                              subPekerjaan.durasi =
                                  int.parse(listController[index].durasi.text);
                              await ApiService()
                                  .updateSubPekerjaan(subPekerjaan);
                              setState(() {});
                              Navigator.pop(context, 'SIMPAN');
                            },
                            child: const Text('SIMPAN'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'BATAL'),
                            child: const Text(
                              'BATAL',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    )
                  },
                  child: Text("EDIT"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  color: Color(0xFF1A73E9),
                  textColor: Colors.white,
                  height: 40,
                ),
                SizedBox(
                  width: 16,
                ),
                MaterialButton(
                  onPressed: () async {
                    setState(() {
                      ApiService().deleteSubPekerjaan(items[index].id);
                      var provider =
                          Provider.of<NotifProvider>(context, listen: false);
                      provider.onChange();
                      widget.loadData();
                    });
                  },
                  child: Text("DELETE"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  color: Color(0xFFEB5757),
                  textColor: Colors.white,
                  height: 40,
                )
              ],
            )
          ]),
        ));
      },
    );
  }
}

class DitolakPage extends StatefulWidget {
  final int? idSubPekerjaan;
  const DitolakPage({Key? key, this.idSubPekerjaan}) : super(key: key);

  @override
  _DitolakPageState createState() => _DitolakPageState();
}

class _DitolakPageState extends State<DitolakPage> {
  late Future<PersetujuanResponse> pekerjaanResponse;
  int idUser = 1;
  int atasanId = 1;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    getLoginData();
    loadPekerjaanData();
  }

  loadPekerjaanData() async {
    pekerjaanResponse = ApiService().getRejectPersetujuan(idUser);
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idUser = sharedPreferences.getInt("id_user")!;
      atasanId = sharedPreferences.getInt("atasan_id")!;
      loadPekerjaanData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8,
          ),
          FutureBuilder<PersetujuanResponse>(
              future: pekerjaanResponse,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!.data;
                  List<PersetujuanPekerjaan> listPekerjaan = data;
                  if (listPekerjaan.length > 0) {
                    if (widget.idSubPekerjaan != null) {
                      var position = listPekerjaan.indexWhere(
                          (element) => element.id == widget.idSubPekerjaan!);
                      SchedulerBinding.instance!
                          .addPostFrameCallback((timeStamp) {
                        itemScrollController.jumpTo(
                            index: position, alignment: 0);
                      });
                    }
                    return Expanded(
                      child: ScrollablePositionedList.builder(
                          itemScrollController: itemScrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: listPekerjaan.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listPekerjaan[index].nama,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                PekerjaanDitolakCard(
                                  listSubPekerjaan:
                                      listPekerjaan[index].subPekerjaan,
                                  loadData: getLoginData,
                                  idAtasan: atasanId,
                                  idUser: idUser,
                                )
                              ],
                            );
                          }),
                    );
                  } else {
                    return Center(
                      child: Text("Tidak ada pekerjaan yang ditolak"),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text("Error");
                }
                return CircularProgressIndicator();
              }),
        ],
      ),
    );
  }
}

class PekerjaanDitolakCard extends StatefulWidget {
  final List<SubPekerjaan> listSubPekerjaan;
  final Function loadData;
  final int idAtasan;
  final int idUser;
  const PekerjaanDitolakCard(
      {Key? key,
      required this.listSubPekerjaan,
      required this.loadData,
      required this.idAtasan,
      required this.idUser})
      : super(key: key);

  @override
  _PekerjaanDitolakCardState createState() => _PekerjaanDitolakCardState();
}

class _PekerjaanDitolakCardState extends State<PekerjaanDitolakCard> {
  List<SubPekerjaan> items = [];
  List<EditingContoller> listController = [];

  @override
  void initState() {
    items = widget.listSubPekerjaan;
    listController = List<EditingContoller>.generate(
        items.length,
        (index) => EditingContoller(
            nama: TextEditingController(),
            keterangan: TextEditingController(),
            durasi: TextEditingController(),
            tanggal: TextEditingController()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<SettingProvider>(context);
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          listController[index].nama.text = items[index].nama;
          listController[index].durasi.text = items[index].durasi.toString();
          listController[index].tanggal.text = items[index].tanggal;
          return Card(
              child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                items[index].nama,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                items[index].tanggal,
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                (() {
                  if (items[index].durasi < 10) {
                    return "Durasi: 00:0${items[index].durasi}";
                  } else if (items[index].durasi > 59) {
                    int jam = items[index].durasi ~/ 60;
                    int menit = items[index].durasi % 60;
                    if (menit < 10) {
                      return "Durasi: 0$jam:0$menit";
                    }
                    return "Durasi: $jam:$menit";
                  } else {
                    return "Durasi: 00:${items[index].durasi}";
                  }
                }()),
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                "Saran: ${items[index].saran}",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  MaterialButton(
                    onPressed: () => {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Edit Pekerjaan'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child: TextFormField(
                                  controller: listController[index].nama,
                                  decoration: InputDecoration(
                                      labelText: "Nama Pekerjaan",
                                      hintText: "Nama Pekerjaan",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                child: GestureDetector(
                                  onTap: () async {
                                    return await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Container(
                                              height: 200,
                                              width: 300,
                                              child: CupertinoTimerPicker(
                                                onTimerDurationChanged:
                                                    (duration) => {
                                                  listController[index]
                                                          .durasi
                                                          .text =
                                                      duration.inMinutes
                                                          .toString()
                                                },
                                                mode:
                                                    CupertinoTimerPickerMode.hm,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("OK")),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("BATAL"))
                                            ],
                                          );
                                        });
                                  },
                                  child: TextFormField(
                                    enabled: false,
                                    controller: listController[index].durasi,
                                    decoration: InputDecoration(
                                        labelText: "Durasi",
                                        hintText: "Durasi",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  DateTime itemDate =
                                      DateFormat("yyyy-MM-dd HH:mm:ss").parse(
                                          listController[index].tanggal.text);
                                  final date = await showDatePicker(
                                      context: context,
                                      initialDate: itemDate,
                                      lastDate: itemDate,
                                      firstDate: itemDate.subtract(Duration(
                                          days: settingProvider.numBackDate -
                                              1)));
                                  if (date != null) {
                                    String formatTime = DateFormat("HH:mm:ss")
                                        .format(DateTime.now());
                                    String formatDate =
                                        DateFormat("yyyy-MM-dd").format(date);
                                    listController[index].tanggal.text =
                                        "$formatDate $formatTime";
                                  }
                                },
                                child: TextFormField(
                                  enabled: false,
                                  controller: listController[index].tanggal,
                                  decoration: InputDecoration(
                                      labelText: "Tanggal",
                                      hintText: "Tanggal",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                var subPekerjaan = items[index];
                                subPekerjaan.nama =
                                    listController[index].nama.text;
                                subPekerjaan.tanggal =
                                    listController[index].tanggal.text;
                                subPekerjaan.durasi = int.parse(
                                    listController[index].durasi.text);
                                await ApiService()
                                    .updateSubPekerjaan(subPekerjaan);
                                setState(() {});
                                Navigator.pop(context, 'SIMPAN');
                              },
                              child: const Text('SIMPAN'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'BATAL'),
                              child: const Text(
                                'BATAL',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      )
                    },
                    child: Text("EDIT"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    color: Color(0xFF1A73E9),
                    textColor: Colors.white,
                    height: 40,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      setState(() {
                        ApiService().deleteSubPekerjaan(items[index].id);
                        widget.loadData();
                      });
                    },
                    child: Text("DELETE"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    color: Color(0xFFEB5757),
                    textColor: Colors.white,
                    height: 40,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      var subPekerjaan = items[index];
                      subPekerjaan.status = "submit";
                      ApiService().createSubmitNotif(
                          widget.idAtasan, subPekerjaan.id, widget.idUser);
                      await ApiService().updateSubPekerjaan(subPekerjaan);
                      setState(() {
                        widget.loadData();
                      });
                      var provider =
                          Provider.of<NotifProvider>(context, listen: false);
                      provider.onChange();
                    },
                    child: Text("SUBMIT"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    color: Color(0xFF00FF57),
                    textColor: Colors.white,
                    height: 40,
                  ),
                ],
              )
            ]),
          ));
        });
  }
}

class EditingContoller {
  TextEditingController nama;
  TextEditingController keterangan;
  TextEditingController durasi;
  TextEditingController tanggal;

  EditingContoller(
      {required this.nama,
      required this.keterangan,
      required this.durasi,
      required this.tanggal});
}
