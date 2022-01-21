import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengumuman.dart';
import 'package:daily_log/model/PengumumanResponse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({Key? key}) : super(key: key);

  @override
  _PengumumanPageState createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  late Future<PengumumanResponse> pengumumanResponse;
  TextEditingController _namaPekerjaanController = TextEditingController();
  TextEditingController _namaUpdatePekerjaanController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDataPengumuman();
  }

  loadDataPengumuman() {
    pengumumanResponse = ApiService().getListPengumuman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengumuman"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Tambah Pengumuman'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      child: TextFormField(
                        controller: _namaPekerjaanController,
                        decoration: InputDecoration(
                            labelText: "Pengumuman",
                            hintText: "Pengumuman",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ]),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        var now = DateTime.now();
                        var tanggal = DateFormat("yyyy-MM-dd").format(now);
                        Pengumuman pengumuman = Pengumuman(
                            id: 1,
                            pengumuman: _namaPekerjaanController.text,
                            tanggal: tanggal);
                        ApiService().submitPengumuman(pengumuman);
                        setState(() {
                          loadDataPengumuman();
                        });
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
                );
              });
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: FutureBuilder<PengumumanResponse>(
            future: pengumumanResponse,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Pengumuman> listPengumuman = snapshot.data!.data;
                if (listPengumuman.length > 0) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daftar Pengumuman",
                          style: TextStyle(fontSize: 18),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: listPengumuman.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(listPengumuman[index].pengumuman),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  _namaUpdatePekerjaanController
                                                          .text =
                                                      listPengumuman[index]
                                                          .pengumuman;
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Edit Pengumuman'),
                                                    content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  _namaUpdatePekerjaanController,
                                                              decoration: InputDecoration(
                                                                  labelText:
                                                                      "Pengumuman",
                                                                  hintText:
                                                                      "Pengumuman",
                                                                  hintStyle: TextStyle(
                                                                      color: Colors
                                                                          .grey),
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10))),
                                                            ),
                                                          ),
                                                        ]),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () async {
                                                          listPengumuman[index]
                                                                  .pengumuman =
                                                              _namaUpdatePekerjaanController
                                                                  .text;
                                                          ApiService()
                                                              .updatePengumuman(
                                                                  listPengumuman[
                                                                      index]);
                                                          setState(() {
                                                            loadDataPengumuman();
                                                          });
                                                          Navigator.pop(context,
                                                              'SIMPAN');
                                                        },
                                                        child: const Text(
                                                            'SIMPAN'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                'BATAL'),
                                                        child: const Text(
                                                          'BATAL',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Icon(Icons.edit)),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Hapus Pengumuman'),
                                                    content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                              child: Text(
                                                                  "Apakah Anda yakin untuk menghapus pengumuman \n \"${listPengumuman[index].pengumuman}\"?")),
                                                        ]),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () async {
                                                          ApiService()
                                                              .deletePekerjaan(
                                                                  listPengumuman[
                                                                          index]
                                                                      .id);
                                                          setState(() {
                                                            loadDataPengumuman();
                                                          });
                                                          Navigator.pop(context,
                                                              'DELETE');
                                                        },
                                                        child: const Text(
                                                            'DELETE'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                'BATAL'),
                                                        child: const Text(
                                                          'BATAL',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Icon(Icons.delete))
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  );
                } else {
                  return Text("Tekan \"+\" untuk menambahkan pekerjaan");
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
