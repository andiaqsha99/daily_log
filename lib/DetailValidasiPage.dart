import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:flutter/material.dart';

class DetailValidasePage extends StatelessWidget {
  final Pengguna staff;
  const DetailValidasePage({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(this.staff.username),
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
  late Future<SubPekerjaanResponse> listPekerjaanSubmit;
  List<SubPekerjaan> items = [];

  @override
  void initState() {
    super.initState();
    listPekerjaanSubmit =
        ApiService().getSubmitPekerjaanByIdPengguna(widget.idStaff);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            FutureBuilder<SubPekerjaanResponse>(
                future: listPekerjaanSubmit,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    items.addAll(snapshot.data!.data);
                    if (items.length > 0) {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ValidasiCard(
                              subPekerjaan: items[index],
                            );
                          });
                    } else {
                      return Center(
                        child: Text("No Data"),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error"),
                    );
                  }
                  return CircularProgressIndicator();
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
                    onPressed: () => {Navigator.of(context).pop()},
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
                        var update = ApiService().updateSubPekerjaan(element);
                      });
                      Navigator.of(context).pop();
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
            Text(widget.subPekerjaan.durasi < 10
                ? "Durasi: 00:0${widget.subPekerjaan.durasi}"
                : "Durasi: 00:${widget.subPekerjaan.durasi}"),
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
