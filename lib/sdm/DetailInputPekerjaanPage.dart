import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailInputPekerjaanPage extends StatefulWidget {
  final Pengguna pengguna;
  const DetailInputPekerjaanPage({Key? key, required this.pengguna})
      : super(key: key);

  @override
  _DetailInputPekerjaanPageState createState() =>
      _DetailInputPekerjaanPageState();
}

class _DetailInputPekerjaanPageState extends State<DetailInputPekerjaanPage> {
  late Future<PekerjaanResponse> pekerjaanResponse;
  TextEditingController _namaPekerjaanController = TextEditingController();
  TextEditingController _namaUpdatePekerjaanController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDataPekerjaan();
  }

  loadDataPekerjaan() {
    pekerjaanResponse = ApiService().getPekerjaan(widget.pengguna.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Input Pekerjaan"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Tambah Pekerjaan'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      child: TextFormField(
                        controller: _namaPekerjaanController,
                        decoration: InputDecoration(
                            labelText: "Nama pekerjaan",
                            hintText: "Nama Pekerjaan",
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
                        Pekerjaan pekerjaan = Pekerjaan(
                            id: 1,
                            nama: _namaPekerjaanController.text,
                            idUser: widget.pengguna.id,
                            tanggal: tanggal);
                        ApiService().submitPekerjaan(pekerjaan);
                        setState(() {
                          loadDataPekerjaan();
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
        child: FutureBuilder<PekerjaanResponse>(
            future: pekerjaanResponse,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Pekerjaan> listPekerjaan = snapshot.data!.data;
                if (listPekerjaan.length > 0) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daftar Pekerjaan",
                          style: TextStyle(fontSize: 18),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: listPekerjaan.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(listPekerjaan[index].nama),
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
                                                      listPekerjaan[index].nama;
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Edit Pekerjaan'),
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
                                                                      "Nama pekerjaan",
                                                                  hintText:
                                                                      "Nama Pekerjaan",
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
                                                          listPekerjaan[index]
                                                                  .nama =
                                                              _namaUpdatePekerjaanController
                                                                  .text;
                                                          ApiService()
                                                              .updatePekerjaan(
                                                                  listPekerjaan[
                                                                      index]);
                                                          setState(() {
                                                            loadDataPekerjaan();
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
                                                        'Hapus Pekerjaan'),
                                                    content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                              child: Text(
                                                                  "Apakah Anda yakin untuk menghapus pekerjaan \n \"${listPekerjaan[index].nama}\"?")),
                                                        ]),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () async {
                                                          ApiService()
                                                              .deletePekerjaan(
                                                                  listPekerjaan[
                                                                          index]
                                                                      .id);
                                                          setState(() {
                                                            loadDataPekerjaan();
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
