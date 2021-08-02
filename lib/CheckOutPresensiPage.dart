import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:flutter/material.dart';

class CheckOutPresensiPage extends StatelessWidget {
  const CheckOutPresensiPage({Key? key}) : super(key: key);

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "PRESENSI PEGAWAI TANGGAL 30-07-2021",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
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
                    MaterialButton(
                      onPressed: () => {},
                      height: 48,
                      minWidth: 96,
                      color: Color(0xFFF48D2E),
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "CHECK OUT",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MenuBottom()
        ],
      )),
    );
  }
}
