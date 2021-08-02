import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:flutter/material.dart';

class CheckInPresensiPage extends StatelessWidget {
  const CheckInPresensiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kehadiran"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            value: 1, groupValue: "aa", onChanged: (aa) => {}),
                        Text("Sehat"),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      children: [
                        Radio(
                            value: 1, groupValue: "aa", onChanged: (aa) => {}),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    onPressed: () => {},
                    height: 48,
                    minWidth: 96,
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
          MenuBottom()
        ],
      )),
    );
  }
}
