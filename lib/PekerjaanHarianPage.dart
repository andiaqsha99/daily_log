import 'package:daily_log/HomePage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pekerjaan.dart';
import 'package:daily_log/model/PekerjaanResponse.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PekerjaanHarianPage extends StatefulWidget {
  final int idUser;
  const PekerjaanHarianPage({Key? key, required this.idUser}) : super(key: key);

  @override
  _PekerjaanHarianPageState createState() => _PekerjaanHarianPageState();
}

class _PekerjaanHarianPageState extends State<PekerjaanHarianPage> {
  late Future<PekerjaanResponse> pekerjaanResponse;
  List<SubPekerjaan> listSubPekerjaan = [SubPekerjaan()];
  List<List<SubPekerjaan>> mapPekerjaan = [];

  @override
  void initState() {
    super.initState();
    pekerjaanResponse = ApiService().getPekerjaan(widget.idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pekerjaan Harian"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfilStatus(),
            Container(
              padding: EdgeInsets.only(left: 16, top: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                "Tupoksi",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            FutureBuilder<PekerjaanResponse>(
                future: pekerjaanResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var listPekerjaan = snapshot.data;
                    List<Pekerjaan> items = listPekerjaan!.data;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        mapPekerjaan.add([newSubPekerjaan(items[index].id)]);
                        return PekerjaanListWidget(
                          headerText: items[index].nama,
                          idPekerjaan: items[index].id,
                          listSubPekerjaan: mapPekerjaan[index],
                        );
                      },
                      itemCount: items.length,
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  }

                  return CircularProgressIndicator();
                }),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: MaterialButton(
                onPressed: () async {
                  mapPekerjaan.forEach((element) {
                    element.forEach((element) {
                      print(element.nama);
                      ApiService().submitSubPekerjaan(element);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return HomePage();
                      }));
                    });
                  });
                },
                height: 56,
                minWidth: 96,
                color: Colors.blue,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "SUBMIT",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: MenuBottom(),
    );
  }
}

class PekerjaanListWidget extends StatefulWidget {
  final String headerText;
  final int idPekerjaan;
  final List<SubPekerjaan> listSubPekerjaan;
  const PekerjaanListWidget(
      {Key? key,
      required this.headerText,
      required this.idPekerjaan,
      required this.listSubPekerjaan})
      : super(key: key);

  @override
  _PekerjaanListWidgetState createState() => _PekerjaanListWidgetState();
}

class _PekerjaanListWidgetState extends State<PekerjaanListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      maintainState: true,
      title: Text(widget.headerText),
      children: [
        ListView.builder(
            shrinkWrap: true,
            itemCount: widget.listSubPekerjaan.length,
            itemBuilder: (context, index) {
              return InputPekerjaanWidget(
                subPekerjaan: widget.listSubPekerjaan[index],
              );
            }),
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: MaterialButton(
            onPressed: () {
              setState(() {
                widget.listSubPekerjaan
                    .add(newSubPekerjaan(widget.idPekerjaan));
              });
            },
            height: 56,
            minWidth: 96,
            color: Colors.blue,
            textColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(
              "TAMBAH",
              style: TextStyle(fontSize: 14),
            ),
          ),
        )
      ],
    );
  }
}

SubPekerjaan newSubPekerjaan(int idPekerjaan) {
  DateTime date = DateTime.now();
  String formatDate = DateFormat("yyyy-MM-dd").format(date);
  return SubPekerjaan(
      idPekerjaan: idPekerjaan, tanggal: formatDate, status: 'submit');
}

class InputPekerjaanWidget extends StatefulWidget {
  final SubPekerjaan subPekerjaan;
  const InputPekerjaanWidget({Key? key, required this.subPekerjaan})
      : super(key: key);

  @override
  _InputPekerjaanWidgetState createState() => _InputPekerjaanWidgetState();
}

class _InputPekerjaanWidgetState extends State<InputPekerjaanWidget> {
  String duration = "00:00";
  int jam = 1;
  int menit = 1;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  currentJamValue(value) {
    setState(() {
      jam = value;
      widget.subPekerjaan.durasi = jam;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Keterangan"),
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
                              setState(() => duration = "$jam:$menit");
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
