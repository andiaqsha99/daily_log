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
import 'package:daily_log/api/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CATHRIN"),
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
  Color cardColor = Color(0xffffcccb);
  Color iconColor = Colors.black;
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
                color: cardColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        DateTime dateTime = DateTime.now();
                        var date = DateFormat("yyyy-MM-dd").format(dateTime);
                        var presenceResponse =
                            await ApiService().getTodayPresence(idUSer, date);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          if (presenceResponse.data.isEmpty) {
                            return CheckInPresensiPage(idUser: this.idUSer);
                          } else {
                            return CheckOutPresensiPage(
                              idUser: this.idUSer,
                            );
                          }
                        }));
                      },
                      icon: Icon(
                        Icons.alarm,
                        color: iconColor,
                      ),
                      iconSize: 72,
                    ),
                    Text("Kehadiran",
                        style: TextStyle(
                          color: iconColor,
                        ))
                  ],
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                // color: Color(0xFFB0D8FD),
                color: cardColor,
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
                        color: iconColor,
                      ),
                      iconSize: 72,
                    ),
                    Text("Pekerjaan Harian",
                        style: TextStyle(
                          color: iconColor,
                        ))
                  ],
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                // color: Color(0xFFB0D8FD),
                color: cardColor,
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
                      icon: Icon(Icons.assignment_ind, color: iconColor),
                      iconSize: 72,
                    ),
                    Text("Laporan Kinerja",
                        style: TextStyle(
                          color: iconColor,
                        ))
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                // color: Color(0xFFB0D8FD),
                color: cardColor,
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
                        color: iconColor,
                      ),
                      iconSize: 72,
                    ),
                    Text("Persetujuan",
                        style: TextStyle(
                          color: iconColor,
                        ))
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                // color: Color(0xFFB0D8FD),
                color: cardColor,
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
                        color: iconColor,
                      ),
                      iconSize: 72,
                    ),
                    Text("QR Code",
                        style: TextStyle(
                          color: iconColor,
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
                  color: cardColor,
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
                          color: iconColor,
                        ),
                        iconSize: 72,
                      ),
                      Text("Dashboard",
                          style: TextStyle(
                            color: iconColor,
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
