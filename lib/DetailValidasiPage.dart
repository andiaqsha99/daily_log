import 'package:daily_log/HomePage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PersetujuanPekerjaan.dart';
import 'package:daily_log/model/PersetujuanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailValidasePage extends StatelessWidget {
  final Pengguna staff;
  const DetailValidasePage({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: staff.nip == "000000"
            ? Text(staff.username)
            : Text(Provider.of<UsersProvider>(context)
                .getUsers(this.staff.nip)
                .name),
        actions: [NotificationWidget()],
      ),
      body: SafeArea(
          child: ListValidasiPekerjaanPage(
        idStaff: staff.id,
      )),
      bottomNavigationBar: MenuBottom(),
    );
  }
}

class ListValidasiPekerjaanPage extends StatefulWidget {
  final int idStaff;
  const ListValidasiPekerjaanPage({Key? key, required this.idStaff})
      : super(key: key);

  @override
  _ListValidasiPekerjaanPageState createState() =>
      _ListValidasiPekerjaanPageState();
}

class _ListValidasiPekerjaanPageState extends State<ListValidasiPekerjaanPage> {
  late Future<PersetujuanResponse> listPekerjaanSubmit;
  List<PersetujuanPekerjaan> items = [];

  @override
  void initState() {
    super.initState();
    listPekerjaanSubmit = ApiService().getSubmitPersetujuan(widget.idStaff);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            FutureBuilder<PersetujuanResponse>(
                future: listPekerjaanSubmit,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    items.addAll(snapshot.data!.data);
                    if (items.length > 0) {
                      return Column(
                        children: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(items[index].nama,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            items[index].subPekerjaan.length,
                                        itemBuilder: (context, indeks) {
                                          return ValidasiCard(
                                            subPekerjaan: items[index]
                                                .subPekerjaan[indeks],
                                          );
                                        }),
                                  ],
                                );
                              }),
                          SizedBox(
                            height: 8,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MaterialButton(
                                  onPressed: () =>
                                      {Navigator.of(context).pop()},
                                  child: Text("KEMBALI"),
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
                                    items.forEach((element) {
                                      element.subPekerjaan
                                          .forEach((subpekerjaan) {
                                        ApiService()
                                            .updateSubPekerjaan(subpekerjaan);
                                        if (subpekerjaan.status == 'reject') {
                                          ApiService().createRejectNotif(
                                              element.idUser, subpekerjaan.id);
                                        }
                                      });
                                    });
                                    AlertDialog alertDialog = AlertDialog(
                                      content:
                                          Text("Validasi pekerjaan berhasil"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomePage()));
                                            },
                                            child: Text("OK"))
                                      ],
                                    );
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return alertDialog;
                                        });
                                  },
                                  child: Text("VALIDASI"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  color: Color(0xFF1A73E9),
                                  textColor: Colors.white,
                                  height: 40,
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Text("Tidak ada Data"),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error"),
                    );
                  }
                  return CircularProgressIndicator();
                }),
          ],
        ),
      ),
    );
  }
}

class ValidasiCard extends StatefulWidget {
  final SubPekerjaan subPekerjaan;
  const ValidasiCard({Key? key, required this.subPekerjaan}) : super(key: key);

  @override
  _ValidasiCardState createState() => _ValidasiCardState();
}

class _ValidasiCardState extends State<ValidasiCard> {
  bool isChecked = true;
  late TextEditingController _textSaranController;

  @override
  void initState() {
    super.initState();
    _textSaranController = TextEditingController();
    isChecked
        ? widget.subPekerjaan.status = 'valid'
        : widget.subPekerjaan.status = 'reject';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subPekerjaan.nama,
              style: TextStyle(fontSize: 16),
            ),
            Text((() {
              if (widget.subPekerjaan.durasi < 10) {
                return "Durasi: 00:0${widget.subPekerjaan.durasi}";
              } else if (widget.subPekerjaan.durasi > 59) {
                int jam = widget.subPekerjaan.durasi ~/ 60;
                int menit = widget.subPekerjaan.durasi % 60;
                if (menit < 10) {
                  return "Durasi: 0$jam:0$menit";
                }
                return "Durasi: $jam:$menit";
              } else {
                return "Durasi: 00:${widget.subPekerjaan.durasi}";
              }
            }())),
            Row(
              children: [
                Text("Validasi"),
                Switch(
                    value: isChecked,
                    onChanged: (val) => {
                          setState(() {
                            isChecked = val;
                            val
                                ? widget.subPekerjaan.status = 'valid'
                                : widget.subPekerjaan.status = 'reject';
                          })
                        })
              ],
            ),
            if (!isChecked) Text("Saran"),
            if (!isChecked) SizedBox(height: 8),
            if (!isChecked)
              TextFormField(
                onChanged: (value) {
                  widget.subPekerjaan.saran = value;
                },
                controller: _textSaranController,
                decoration: InputDecoration(
                    hintText: "Saran",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              )
          ],
        ),
      ),
    );
  }
}
