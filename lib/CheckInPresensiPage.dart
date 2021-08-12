import 'package:daily_log/CheckOutPresensiPage.dart';
import 'package:daily_log/HomePage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInPresensiPage extends StatefulWidget {
  const CheckInPresensiPage({Key? key}) : super(key: key);

  @override
  _CheckInPresensiPageState createState() => _CheckInPresensiPageState();
}

class _CheckInPresensiPageState extends State<CheckInPresensiPage> {
  int valueRadio = 0;
  bool valueCheck = false;
  bool valueCheck1 = false;
  bool valueCheck2 = false;
  bool valueCheck3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kehadiran"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
        ],
      ),
      bottomSheet: MenuBottom(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ProfilStatus(),
            Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kota/Kabupaten"),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                          fillColor: Color(0xFFE3F5FF),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text("Kondisi saat ini")),
                      Expanded(
                          child: Row(
                        children: [
                          Radio(
                              value: 0,
                              groupValue: valueRadio,
                              onChanged: (int? val) {
                                setState(() {
                                  valueRadio = val!;
                                });
                              }),
                          Text("Sehat"),
                        ],
                      )),
                      Expanded(
                          child: Row(
                        children: [
                          Radio(
                              value: 1,
                              groupValue: valueRadio,
                              onChanged: (int? val) => {
                                    setState(() {
                                      valueRadio = val!;
                                    })
                                  }),
                          Text("Sakit"),
                        ],
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text("Suhu Tubuh"),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                          fillColor: Color(0xFFE3F5FF),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  valueRadio == 1 ? listCheckBox() : SizedBox(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                      onPressed: () async {
                        var sharedPreference =
                            await SharedPreferences.getInstance();
                        sharedPreference.setBool("is_checkin", true);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                      height: 48,
                      color: Colors.blue,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "CHECK IN",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget listCheckBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Keterangan"),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: valueCheck,
          onChanged: (value) {
            setState(() {
              this.valueCheck = value!;
            });
          },
          title: Text("Suhu tubuh lebih dari 37 derajat"),
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: valueCheck1,
          onChanged: (value) {
            setState(() {
              this.valueCheck1 = value!;
            });
          },
          title: Text("Gangguan Pernafasan"),
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: valueCheck2,
          onChanged: (value) {
            setState(() {
              this.valueCheck2 = value!;
            });
          },
          title: Text("Batuk"),
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: valueCheck3,
          onChanged: (value) {
            setState(() {
              this.valueCheck3 = value!;
            });
          },
          title: Text("Flu"),
        ),
        Row(
          children: [
            SizedBox(
              width: 24,
            ),
            Text("Lainnya"),
            SizedBox(
              width: 36,
            ),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                    fillColor: Color(0xFFE3F5FF),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        )
      ],
    );
  }
}
