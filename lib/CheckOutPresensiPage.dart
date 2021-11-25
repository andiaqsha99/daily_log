import 'package:daily_log/HomePage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Presence.dart';
import 'package:daily_log/model/PresenceResponse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOutPresensiPage extends StatefulWidget {
  final int idUser;
  const CheckOutPresensiPage({Key? key, required this.idUser})
      : super(key: key);

  @override
  _CheckOutPresensiPageState createState() => _CheckOutPresensiPageState();
}

class _CheckOutPresensiPageState extends State<CheckOutPresensiPage> {
  late Future<PresenceResponse> presenceResponse;
  late Presence updatePresence;
  String date = "dd-MM-yyyy";

  @override
  void initState() {
    super.initState();
    DateTime dateTime = DateTime.now();
    date = DateFormat("yyyy-MM-dd").format(dateTime);
    presenceResponse = ApiService().getTodayPresence(widget.idUser, date);

    date = DateFormat("dd-MM-yyyy").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kehadiran"),
        actions: [NotificationWidget()],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ProfilStatus(),
          Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<PresenceResponse>(
                    future: presenceResponse,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Presence presence = snapshot.data!.data.last;
                        updatePresence = presence;
                        return Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Presensi tanggal $date",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "Jam Check In: ${presence.checkInTime},",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "Kabupaten/Kota: ${presence.city},",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "Suhu tubuh ${presence.temperature} derajat,",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "Kondisi ${presence.conditions},",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              if (presence.notes != null)
                                Text(
                                  "Keterangan: ${presence.notes}",
                                  style: TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text("Something Error");
                      }
                      return CircularProgressIndicator();
                    }),
                SizedBox(
                  height: 32,
                ),
                MaterialButton(
                  onPressed: () async {
                    DateTime dateTime = DateTime.now();
                    String checkOutTime =
                        DateFormat("HH:mm:ss").format(dateTime);
                    updatePresence.checkOutTime = checkOutTime;
                    await ApiService().updatePresence(updatePresence);
                    var sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.setBool("is_checkin", false);
                    AlertDialog alertDialog = AlertDialog(
                      content: Text("Check Out berhasil"),
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
                  },
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
          ),
          MenuBottom()
        ],
      ),
    );
  }
}
