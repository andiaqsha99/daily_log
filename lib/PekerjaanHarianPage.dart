import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PekerjaanHarianPage extends StatefulWidget {
  const PekerjaanHarianPage({Key? key}) : super(key: key);

  @override
  _PekerjaanHarianPageState createState() => _PekerjaanHarianPageState();
}

class _PekerjaanHarianPageState extends State<PekerjaanHarianPage> {
  var items = List<String>.generate(4, (index) => "Pekerjaan $index");

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
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return PekerjaanListWidget(headerText: items[index]);
              },
              itemCount: items.length,
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: MaterialButton(
                onPressed: () => {},
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
  const PekerjaanListWidget({Key? key, required this.headerText})
      : super(key: key);

  @override
  _PekerjaanListWidgetState createState() => _PekerjaanListWidgetState();
}

class _PekerjaanListWidgetState extends State<PekerjaanListWidget> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = 1;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      maintainState: true,
      title: Text(widget.headerText),
      children: [
        ListView.builder(
            shrinkWrap: true,
            itemCount: _counter,
            itemBuilder: (context, index) {
              return InputPekerjaanWidget();
            }),
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: MaterialButton(
            onPressed: () {
              setState(() {
                _counter += 1;
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

class InputPekerjaanWidget extends StatefulWidget {
  const InputPekerjaanWidget({Key? key}) : super(key: key);

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
