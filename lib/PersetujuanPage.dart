import 'package:daily_log/MenuBottom.dart';
import 'package:flutter/material.dart';

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

class MenungguPage extends StatelessWidget {
  const MenungguPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pekerjaan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Text("Kategori Pekerjaan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            PekerjaanMenungguCard()
          ],
        ),
      ),
    );
  }
}

class PekerjaanMenungguCard extends StatefulWidget {
  const PekerjaanMenungguCard({Key? key}) : super(key: key);

  @override
  _PekerjaanMenungguCardState createState() => _PekerjaanMenungguCardState();
}

class _PekerjaanMenungguCardState extends State<PekerjaanMenungguCard> {
  List<Pekerjaan> listPekerjaan = List<Pekerjaan>.generate(
      6,
      (index) => Pekerjaan(
          nama: "Pekerjaan $index",
          tanggal: "$index/07/2021",
          durasi: "01:00",
          keterangan: "keterangan $index"));

  List<EditingContoller> listController = List<EditingContoller>.generate(
      6,
      (index) => EditingContoller(
          nama: TextEditingController(),
          keterangan: TextEditingController(),
          durasi: TextEditingController(),
          tanggal: TextEditingController()));

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Card(
            child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              listPekerjaan[index].nama,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              listPekerjaan[index].tanggal,
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              listPekerjaan[index].durasi,
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              listPekerjaan[index].keterangan,
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
                                    hintText: "Nama Pekerjaan",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              child: TextFormField(
                                controller: listController[index].keterangan,
                                decoration: InputDecoration(
                                    hintText: "Keterangan",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              child: TextFormField(
                                controller: listController[index].durasi,
                                decoration: InputDecoration(
                                    hintText: "Durasi",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              child: TextFormField(
                                controller: listController[index].tanggal,
                                decoration: InputDecoration(
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
                            onPressed: () {
                              Navigator.pop(context, 'SIMPAN');
                              setState(() {
                                listPekerjaan[index].nama =
                                    listController[index].nama.text;
                                listPekerjaan[index].keterangan =
                                    listController[index].keterangan.text;
                                listPekerjaan[index].durasi =
                                    listController[index].durasi.text;
                                listPekerjaan[index].tanggal =
                                    listController[index].tanggal.text;
                              });
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
                  onPressed: () => {
                    setState(() {
                      listPekerjaan.removeAt(index);
                    })
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
      itemCount: listPekerjaan.length,
    );
  }
}

class DitolakPage extends StatelessWidget {
  const DitolakPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pekerjaan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Text("Kategori Pekerjaan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            PekerjaanDitolakCard(),
          ],
        ),
      ),
    );
  }
}

class PekerjaanDitolakCard extends StatefulWidget {
  const PekerjaanDitolakCard({Key? key}) : super(key: key);

  @override
  _PekerjaanDitolakCardState createState() => _PekerjaanDitolakCardState();
}

class _PekerjaanDitolakCardState extends State<PekerjaanDitolakCard> {
  List<Pekerjaan> listPekerjaan = List<Pekerjaan>.generate(
      6,
      (index) => Pekerjaan(
          nama: "Pekerjaan $index",
          tanggal: "$index/07/2021",
          durasi: "01:00",
          keterangan: "keterangan $index"));

  List<EditingContoller> listController = List<EditingContoller>.generate(
      6,
      (index) => EditingContoller(
          nama: TextEditingController(),
          keterangan: TextEditingController(),
          durasi: TextEditingController(),
          tanggal: TextEditingController()));

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listPekerjaan.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Card(
              child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                listPekerjaan[index].nama,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                listPekerjaan[index].tanggal,
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                "Durasi: ${listPekerjaan[index].durasi}",
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                listPekerjaan[index].keterangan,
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
                                      hintText: "Nama Pekerjaan",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                child: TextFormField(
                                  controller: listController[index].keterangan,
                                  decoration: InputDecoration(
                                      hintText: "Keterangan",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                child: TextFormField(
                                  controller: listController[index].durasi,
                                  decoration: InputDecoration(
                                      hintText: "Durasi",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                child: TextFormField(
                                  controller: listController[index].tanggal,
                                  decoration: InputDecoration(
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
                              onPressed: () {
                                Navigator.pop(context, 'SIMPAN');
                                setState(() {
                                  listPekerjaan[index].nama =
                                      listController[index].nama.text;
                                  listPekerjaan[index].keterangan =
                                      listController[index].keterangan.text;
                                  listPekerjaan[index].durasi =
                                      listController[index].durasi.text;
                                  listPekerjaan[index].tanggal =
                                      listController[index].tanggal.text;
                                });
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
                    onPressed: () => {
                      setState(() {
                        listPekerjaan.removeAt(index);
                      })
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
                    onPressed: () => {},
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

class Pekerjaan {
  String nama;
  String tanggal;
  String durasi;
  String keterangan;

  Pekerjaan(
      {required this.nama,
      required this.tanggal,
      required this.durasi,
      required this.keterangan});
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
