import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class PekerjaanHarianPage extends StatelessWidget {
  const PekerjaanHarianPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pekerjaan Harian"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: Column(
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
          PekerjaanListWidget(),
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
      bottomSheet: MenuBottom(),
    );
  }
}

class PekerjaanListWidget extends StatelessWidget {
  const PekerjaanListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var items = List<String>.generate(4, (index) => "Pekerjaan $index");
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(items[index]),
            children: [
              InputPekerjaanWidget(),
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
                    "TAMBAH",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              )
            ],
          );
        },
        itemCount: items.length,
      ),
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
                      content: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [Text("JAM"), Text("MENIT")]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              NumberPicker(
                                  minValue: 1,
                                  maxValue: 12,
                                  value: jam,
                                  infiniteLoop: true,
                                  haptics: true,
                                  onChanged: (val) => currentJamValue(val)),
                              NumberPicker(
                                  minValue: 0,
                                  maxValue: 59,
                                  value: menit,
                                  infiniteLoop: true,
                                  haptics: true,
                                  onChanged: (val) => currentMenitValue(val)),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() => duration = "0$jam:0$menit");
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
