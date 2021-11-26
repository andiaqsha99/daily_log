import 'package:daily_log/CheckInPresensiPage.dart';
import 'package:daily_log/CheckOutPresensiPage.dart';
import 'package:daily_log/DashboardPage.dart';
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
      bottomNavigationBar: MenuBottom(),
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
      children: [
        ProfilStatus(),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 30,
            primary: false,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                // color: Color(0xFFB0D8FD),
                color: Color(0xffD93025),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
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
                      icon: Icon(
                        Icons.alarm,
                        color: Colors.white,
                      ),
                      iconSize: 72,
                    ),
                    Text("Kehadiran",
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                // color: Color(0xFFB0D8FD),
                color: Color(0xffD93025),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PekerjaanHarianPage(
                                      idUser: this.idUSer,
                                    )));
                      },
                      icon: Icon(
                        Icons.desktop_windows,
                        color: Colors.white,
                      ),
                      iconSize: 72,
                    ),
                    Text("Pekerjaan Harian",
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                // color: Color(0xFFB0D8FD),
                color: Color(0xffD93025),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LaporanKinerjaPage(
                                      idUser: this.idUSer,
                                    )));
                      },
                      icon: Icon(Icons.assignment_ind, color: Colors.white),
                      iconSize: 72,
                    ),
                    Text("Laporan Kinerja",
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                // color: Color(0xFFB0D8FD),
                color: Color(0xffD93025),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => jabatan == "staff"
                                    ? PersetujuanPage()
                                    : PersetujuanAtasanPage()));
                      },
                      icon: Icon(
                        Icons.assignment_turned_in,
                        color: Colors.white,
                      ),
                      iconSize: 72,
                    ),
                    Text("Persetujuan",
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                // color: Color(0xFFB0D8FD),
                color: Color(0xffD93025),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return QrCodePage();
                        }));
                      },
                      icon: Icon(
                        Icons.qr_code,
                        color: Colors.white,
                      ),
                      iconSize: 72,
                    ),
                    Text("QR Code",
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              Opacity(
                opacity: jabatan != "atasan" ? 0.0 : 1.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  // color: Color(0xFFB0D8FD),
                  color: Color(0xffD93025),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (jabatan == "atasan") {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DashboardPage(
                                      idUser: this.idUSer,
                                      idPosition: this.idPosition,
                                    )));
                          }
                        },
                        icon: Icon(
                          Icons.dashboard,
                          color: Colors.white,
                        ),
                        iconSize: 72,
                      ),
                      Text("Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
