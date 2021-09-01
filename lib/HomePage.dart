import 'package:daily_log/CheckInPresensiPage.dart';
import 'package:daily_log/CheckOutPresensiPage.dart';
import 'package:daily_log/LaporanKinerjaAtasanPage.dart';
import 'package:daily_log/LaporanKinerjaPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/PekerjaanHarianPage.dart';
import 'package:daily_log/PersetujuanAtasanPage.dart';
import 'package:daily_log/PersetujuanPage.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:daily_log/QrCodePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SAKIRA"),
        actions: [NotificationWidget()],
      ),
      body: SafeArea(child: MenuPage()),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String jabatan = " ";
  int idUSer = 0;
  int idPosition = 0;
  bool isCheckIn = false;

  @override
  void initState() {
    super.initState();
    getLoginData();
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      jabatan = sharedPreferences.getString("jabatan")!;
      idUSer = sharedPreferences.getInt("id_user")!;
      isCheckIn = sharedPreferences.getBool("is_checkin")!;
      idPosition = sharedPreferences.getInt("position_id")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ProfilStatus(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Card(
                        color: Color(0xFFB0D8FD),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => isCheckIn
                                        ? CheckOutPresensiPage(
                                            idUser: this.idUSer,
                                          )
                                        : CheckInPresensiPage(
                                            idUser: this.idUSer)));
                          },
                          icon: Icon(Icons.alarm),
                          iconSize: 56,
                        ),
                      ),
                      Text("Kehadiran")
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  child: Column(
                    children: [
                      Card(
                        color: Color(0xFFB0D8FD),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => jabatan == "staff"
                                        ? LaporanKinerjaPage(
                                            idUser: this.idUSer,
                                          )
                                        : LaporanKinerjaAtasanPage(
                                            idUser: this.idUSer,
                                            idPosition: this.idPosition,
                                          )));
                          },
                          icon: Icon(Icons.assignment_ind),
                          iconSize: 56,
                        ),
                      ),
                      Text("Laporan Kinerja")
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  child: Column(
                    children: [
                      Card(
                        color: Color(0xFFB0D8FD),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return QrCodePage();
                            }));
                          },
                          icon: Icon(Icons.qr_code),
                          iconSize: 56,
                        ),
                      ),
                      Text("QR Code")
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Card(
                        color: Color(0xFFB0D8FD),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PekerjaanHarianPage(
                                          idUser: this.idUSer,
                                        )));
                          },
                          icon: Icon(Icons.desktop_windows),
                          iconSize: 56,
                        ),
                      ),
                      Text("Pekerjaan Harian")
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  child: Column(
                    children: [
                      Card(
                        color: Color(0xFFB0D8FD),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => jabatan == "staff"
                                        ? PersetujuanPage()
                                        : PersetujuanAtasanPage()));
                          },
                          icon: Icon(Icons.assignment_turned_in),
                          iconSize: 56,
                        ),
                      ),
                      Text("Persetujuan")
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Opacity(
                  opacity: 0.0,
                  child: Container(
                    child: Column(
                      children: [
                        Card(
                          color: Color(0xFFB0D8FD),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.assignment_turned_in),
                            iconSize: 56,
                          ),
                        ),
                        Text("Not Visible")
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        MenuBottom()
      ],
    );
  }
}
