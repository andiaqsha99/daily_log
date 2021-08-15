import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersetujuanPage extends StatelessWidget {
  const PersetujuanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
            actions: [
              IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
            ],
          ),
          body: TabBarView(children: [MenungguPage(), DitolakPage()]),
          bottomSheet: MenuBottom(),
        ));
  }
}

class MenungguPage extends StatefulWidget {
  const MenungguPage({Key? key}) : super(key: key);

  @override
  _MenungguPageState createState() => _MenungguPageState();
}

class _MenungguPageState extends State<MenungguPage> {
  late Future<PekerjaanResponse> pekerjaanResponse;
  int idUser = 1;

  @override
  void initState() {
    super.initState();
    getLoginData();
    loadPekerjaanData();
  }

  loadPekerjaanData() async {
    pekerjaanResponse = ApiService().getPekerjaan(idUser);
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
            Text(
              "Tupoksi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            FutureBuilder<PekerjaanResponse>(
                future: pekerjaanResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.data;
                    List<Pekerjaan> listPekerjaan = data;
                    return ListView.builder(
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
                                idPekerjaan: listPekerjaan[index].id,
                              )
                            ],
                          );
                        });
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
  final int idPekerjaan;
  const PekerjaanMenungguCard({Key? key, required this.idPekerjaan})
      : super(key: key);

  @override
  _PekerjaanMenungguCardState createState() => _PekerjaanMenungguCardState();
}

class _PekerjaanMenungguCardState extends State<PekerjaanMenungguCard> {
  late Future<SubPekerjaanResponse> subPekerjaanResponse;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    subPekerjaanResponse = ApiService().getSubmitPekerjaan(widget.idPekerjaan);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubPekerjaanResponse>(
        future: subPekerjaanResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            List<SubPekerjaan> items = data!.data;
            List<EditingContoller> listController =
                List<EditingContoller>.generate(
                    items.length,
                    (index) => EditingContoller(
                        nama: TextEditingController(),
                        keterangan: TextEditingController(),
                        durasi: TextEditingController(),
                        tanggal: TextEditingController()));
            if (items.length > 0) {
              return ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  listController[index].nama.text = items[index].nama;
                  listController[index].durasi.text =
                      items[index].durasi.toString();
                  listController[index].tanggal.text = items[index].tanggal;
                  return Card(
                      child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index].nama,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            items[index].tanggal,
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "0${items[index].durasi}:00",
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
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text('Edit Pekerjaan'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            child: TextFormField(
                                              controller:
                                                  listController[index].nama,
                                              decoration: InputDecoration(
                                                  hintText: "Nama Pekerjaan",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            child: TextFormField(
                                              controller:
                                                  listController[index].durasi,
                                              decoration: InputDecoration(
                                                  hintText: "Durasi",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            child: TextFormField(
                                              controller:
                                                  listController[index].tanggal,
                                              decoration: InputDecoration(
                                                  hintText: "Tanggal",
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
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
                                                listController[index]
                                                    .tanggal
                                                    .text;
                                            subPekerjaan.durasi = int.parse(
                                                listController[index]
                                                    .durasi
                                                    .text);
                                            var update = await ApiService()
                                                .updateSubPekerjaan(
                                                    subPekerjaan);
                                            setState(() {
                                              loadData();
                                            });
                                            Navigator.pop(context, 'SIMPAN');
                                          },
                                          child: const Text('SIMPAN'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'BATAL'),
                                          child: const Text(
                                            'BATAL',
                                            style:
                                                TextStyle(color: Colors.black),
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
                                  var delete = await ApiService()
                                      .deleteSubPekerjaan(items[index].id);
                                  setState(() {
                                    loadData();
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
                itemCount: items.length,
              );
            } else {
              return Center(child: Text("No Data"));
            }
          } else if (snapshot.hasError) {
            return Text("Error");
          }

          return CircularProgressIndicator();
        });
  }
}

class DitolakPage extends StatefulWidget {
  const DitolakPage({Key? key}) : super(key: key);

  @override
  _DitolakPageState createState() => _DitolakPageState();
}

class _DitolakPageState extends State<DitolakPage> {
  late Future<PekerjaanResponse> pekerjaanResponse;
  int idUser = 1;

  @override
  void initState() {
    super.initState();
    getLoginData();
    loadPekerjaanData();
  }

  loadPekerjaanData() async {
    pekerjaanResponse = ApiService().getPekerjaan(idUser);
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idUser = sharedPreferences.getInt("id_user")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tupoksi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            FutureBuilder<PekerjaanResponse>(
                future: pekerjaanResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.data;
                    List<Pekerjaan> listPekerjaan = data;
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: listPekerjaan.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listPekerjaan[index].nama,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              PekerjaanDitolakCard(
                                idPekerjaan: listPekerjaan[index].id,
                              )
                            ],
                          );
                        });
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

class PekerjaanDitolakCard extends StatefulWidget {
  final int idPekerjaan;
  const PekerjaanDitolakCard({Key? key, required this.idPekerjaan})
      : super(key: key);

  @override
  _PekerjaanDitolakCardState createState() => _PekerjaanDitolakCardState();
}

class _PekerjaanDitolakCardState extends State<PekerjaanDitolakCard> {
  late Future<SubPekerjaanResponse> subPekerjaanRejectResponse;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    subPekerjaanRejectResponse =
        ApiService().getRejectPekerjaan(widget.idPekerjaan);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubPekerjaanResponse>(
        future: subPekerjaanRejectResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            List<SubPekerjaan> items = data!.data;
            List<EditingContoller> listController =
                List<EditingContoller>.generate(
                    items.length,
                    (index) => EditingContoller(
                        nama: TextEditingController(),
                        keterangan: TextEditingController(),
                        durasi: TextEditingController(),
                        tanggal: TextEditingController()));
            if (items.length > 0) {
              return ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    listController[index].nama.text = items[index].nama;
                    listController[index].durasi.text =
                        items[index].durasi.toString();
                    listController[index].tanggal.text = items[index].tanggal;
                    return Card(
                        child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[index].nama,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              items[index].tanggal,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "Durasi: 0${items[index].durasi}:00",
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
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text('Edit Pekerjaan'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              child: TextFormField(
                                                controller:
                                                    listController[index].nama,
                                                decoration: InputDecoration(
                                                    hintText: "Nama Pekerjaan",
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Container(
                                              child: TextFormField(
                                                controller:
                                                    listController[index]
                                                        .durasi,
                                                decoration: InputDecoration(
                                                    hintText: "Durasi",
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Container(
                                              child: TextFormField(
                                                controller:
                                                    listController[index]
                                                        .tanggal,
                                                decoration: InputDecoration(
                                                    hintText: "Tanggal",
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10))),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async {
                                              var subPekerjaan = items[index];
                                              subPekerjaan.nama =
                                                  listController[index]
                                                      .nama
                                                      .text;
                                              subPekerjaan.tanggal =
                                                  listController[index]
                                                      .tanggal
                                                      .text;
                                              subPekerjaan.durasi = int.parse(
                                                  listController[index]
                                                      .durasi
                                                      .text);
                                              var update = await ApiService()
                                                  .updateSubPekerjaan(
                                                      subPekerjaan);
                                              loadData();
                                              Navigator.pop(context, 'SIMPAN');
                                            },
                                            child: const Text('SIMPAN'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'BATAL'),
                                            child: const Text(
                                              'BATAL',
                                              style: TextStyle(
                                                  color: Colors.black),
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
                                    var delete = await ApiService()
                                        .deleteSubPekerjaan(items[index].id);
                                    setState(() {
                                      loadData();
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
                                    var update = await ApiService()
                                        .updateSubPekerjaan(subPekerjaan);
                                    setState(() {
                                      loadData();
                                    });
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
            } else {
              return Center(
                child: Text("No Data"),
              );
            }
          } else if (snapshot.hasError) {
            return Text("Error");
          }

          return CircularProgressIndicator();
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
