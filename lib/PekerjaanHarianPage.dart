import 'package:daily_log/HomePage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/SettingProvider.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PekerjaanHarianPage extends StatefulWidget {
  final int idUser;
  const PekerjaanHarianPage({Key? key, required this.idUser}) : super(key: key);

  @override
  _PekerjaanHarianPageState createState() => _PekerjaanHarianPageState();
}

class _PekerjaanHarianPageState extends State<PekerjaanHarianPage> {
  late PekerjaanResponse pekerjaanResponse;
  List<SubPekerjaan> mapPekerjaan = [];
  List<SubPekerjaan> listSubPekerjaan = [];
  int idAtasan = 0;
  DateTime dateFilled = DateTime.now();
  List<Pekerjaan> listPekerjaan = [];
  Pekerjaan? pekerjaanOthers;

  @override
  void initState() {
    super.initState();
    getLoginData();
    getListPekerjaan();
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idAtasan = sharedPreferences.getInt("atasan_id")!;
    });
  }

  getListPekerjaan() async {
    pekerjaanResponse = await ApiService().getPekerjaan(widget.idUser);
    setState(() {
      var templistPekerjaan = pekerjaanResponse.data;
      var indexOthers =
          templistPekerjaan.indexWhere((element) => element.nama == "Others");
      pekerjaanOthers = templistPekerjaan.removeAt(indexOthers);
      templistPekerjaan.add(pekerjaanOthers!);
      listPekerjaan = templistPekerjaan;
    });
  }

  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<SettingProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Pekerjaan Harian"),
        actions: [NotificationWidget()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfilStatus(),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, top: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pekerjaan",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      onPressed: () async {
                        final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            lastDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(Duration(
                                days: settingProvider.numBackDate - 1)));
                        if (date != null) {
                          setState(() {
                            dateFilled = date;
                          });
                        }
                      },
                      child: Text(
                        DateFormat("dd/MM/yyyy").format(dateFilled),
                        style: TextStyle(color: Colors.black),
                      )),
                )
              ],
            ),
            SizedBox(height: 16),
            mapPekerjaan.length == 0
                ? Text("Tekan 'Tambah' untuk memasukkan pekerjaan")
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return PekerjaanListWidget(
                        subPekerjaan: mapPekerjaan[index],
                        listPekerjaan: listPekerjaan,
                      );
                    },
                    itemCount: mapPekerjaan.length,
                  ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        mapPekerjaan
                            .add(newSubPekerjaan(1, widget.idUser, dateFilled));
                      });
                    },
                    height: 56,
                    minWidth: 96,
                    color: Theme.of(context).primaryColor,
                    // textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "TAMBAH",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      DateTime date = DateTime.now();
                      String selectDate =
                          DateFormat("yyyy-MM-dd").format(dateFilled);
                      String formatDate = DateFormat("HH:mm:ss").format(date);

                      mapPekerjaan.forEach((elements) {
                        listSubPekerjaan.add(elements);
                      });

                      SubPekerjaan? check = listSubPekerjaan.firstWhere(
                        (element) =>
                            element.nama == "-" &&
                            element.idPekerjaan == pekerjaanOthers!.id,
                        orElse: () => SubPekerjaan(),
                      );
                      if (check.nama == "-" &&
                          check.idPekerjaan == pekerjaanOthers!.id) {
                        AlertDialog alertDialog = AlertDialog(
                          content: Text("Keterangan wajib diisi"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"))
                          ],
                        );
                        showDialog(
                            context: context,
                            builder: (context) {
                              return alertDialog;
                            });
                      } else {
                        listSubPekerjaan.forEach((element) async {
                          element.tanggal = "$selectDate $formatDate";
                          if (element.nama != '') {
                            var subpekerjaan =
                                await ApiService().submitSubPekerjaan(element);
                            if (subpekerjaan.id != 0) {
                              await ApiService().createSubmitNotif(
                                  idAtasan, subpekerjaan.id, widget.idUser);
                            }
                          }
                        });
                        AlertDialog alertDialog = AlertDialog(
                          content: Text("Submit pekerjaan berhasil"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()));
                                },
                                child: Text("OK"))
                          ],
                        );
                        showDialog(
                            context: context,
                            builder: (context) {
                              return alertDialog;
                            });
                      }
                    },
                    height: 56,
                    minWidth: 96,
                    color: Theme.of(context).primaryColor,
                    // textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "SUBMIT",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 52,
            )
          ],
        ),
      ),
      bottomNavigationBar: MenuBottom(),
    );
  }
}

class PekerjaanListWidget extends StatefulWidget {
  final SubPekerjaan subPekerjaan;
  final List<Pekerjaan> listPekerjaan;
  const PekerjaanListWidget(
      {Key? key, required this.subPekerjaan, required this.listPekerjaan})
      : super(key: key);

  @override
  _PekerjaanListWidgetState createState() => _PekerjaanListWidgetState();
}

class _PekerjaanListWidgetState extends State<PekerjaanListWidget> {
  Pekerjaan? selectedValue;
  @override
  void initState() {
    selectedValue = widget.listPekerjaan[0];
    widget.subPekerjaan.idPekerjaan = selectedValue!.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: DropdownButton<Pekerjaan>(
                    value: selectedValue,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                        widget.subPekerjaan.idPekerjaan = value!.id;
                      });
                    },
                    items: widget.listPekerjaan
                        .map<DropdownMenuItem<Pekerjaan>>((Pekerjaan value) =>
                            DropdownMenuItem<Pekerjaan>(
                                value: value, child: Text(value.nama)))
                        .toList()),
              ),
              InputPekerjaanWidget(
                subPekerjaan: widget.subPekerjaan,
                pekerjaan: selectedValue,
              )
            ],
          ),
        ));
  }
}

SubPekerjaan newSubPekerjaan(int idPekerjaan, int idUser, DateTime dateFilled) {
  DateTime date = DateTime.now();
  String selectDate = DateFormat("yyyy-MM-dd").format(dateFilled);
  String formatDate = DateFormat("HH:mm:ss").format(date);
  return SubPekerjaan(
      nama: "-",
      idPekerjaan: idPekerjaan,
      tanggal: "$selectDate $formatDate",
      status: 'submit',
      idUser: idUser);
}

class InputPekerjaanWidget extends StatefulWidget {
  final Pekerjaan? pekerjaan;
  final SubPekerjaan subPekerjaan;
  const InputPekerjaanWidget(
      {Key? key, required this.subPekerjaan, required this.pekerjaan})
      : super(key: key);

  @override
  _InputPekerjaanWidgetState createState() => _InputPekerjaanWidgetState();
}

class _InputPekerjaanWidgetState extends State<InputPekerjaanWidget> {
  String duration = "00:00";
  int jam = 0;
  int menit = 0;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  currentJamValue(value) {
    setState(() {
      jam = value;
    });
  }

  currentMenitValue(value) {
    setState(() {
      menit = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.pekerjaan!.nama == "Others"
              ? Text("Keterangan (wajib)")
              : Text("Keterangan (opsional)"),
          SizedBox(
            height: 4,
          ),
          Container(
            child: TextFormField(
              onChanged: (value) => widget.subPekerjaan.nama = value,
              controller: _textEditingController,
              decoration: InputDecoration(
                  hintText: "Keterangan",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text("Durasi"),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            child: Container(
              child: IntrinsicWidth(
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                      hintText: duration,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ),
            onTap: () async {
              return await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Container(
                        height: 200,
                        width: 300,
                        child: CupertinoTimerPicker(
                          onTimerDurationChanged: (duration) => {
                            currentJamValue(duration.inHours),
                            currentMenitValue(duration.inMinutes % 60)
                          },
                          mode: CupertinoTimerPickerMode.hm,
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() => duration =
                                  menit < 9 ? "0$jam:0$menit" : "0$jam:$menit");
                              widget.subPekerjaan.durasi = (jam * 60) + menit;
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
          )
        ],
      ),
    );
  }
}
