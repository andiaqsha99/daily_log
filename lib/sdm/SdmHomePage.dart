import 'package:daily_log/sdm/DownloadKinerjaPage.dart';
import 'package:daily_log/sdm/PengumumanPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LoginWrapper.dart';
import 'InputPekerjaanPage.dart';

class SdmHomePage extends StatefulWidget {
  const SdmHomePage({Key? key}) : super(key: key);

  @override
  _SdmHomePageState createState() => _SdmHomePageState();
}

class _SdmHomePageState extends State<SdmHomePage> {
  Color cardColor = Color(0xffffcccb);
  Color iconColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin"), actions: [
        IconButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Keluar"),
                      content: Text("Anda yakin untuk keluar?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'BATAL');
                            },
                            child: Text(
                              "BATAL",
                              style: TextStyle(color: Colors.black),
                            )),
                        TextButton(
                            onPressed: () async {
                              final sharedPreferences =
                                  await SharedPreferences.getInstance();
                              sharedPreferences.clear();
                              sharedPreferences.setBool("isLogin", false);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginWrapper()),
                                  (route) => false);
                            },
                            child: Text("KELUAR"))
                      ],
                    );
                  });
            },
            icon: Icon(
              Icons.logout,
              color: iconColor,
            ))
      ]),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 30,
                  primary: false,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: cardColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DownloadKinerjaPage()));
                            },
                            icon: Icon(
                              Icons.download,
                              color: iconColor,
                            ),
                            iconSize: 72,
                          ),
                          Text("Download laporan",
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
                      color: cardColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InputPekerjaanPage()));
                            },
                            icon: Icon(
                              Icons.note_add,
                              color: iconColor,
                            ),
                            iconSize: 72,
                          ),
                          Text("Input Pekerjaan",
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
                      color: cardColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PengumumanPage()));
                            },
                            icon: Icon(
                              Icons.announcement,
                              color: iconColor,
                            ),
                            iconSize: 72,
                          ),
                          Text("Pengumuman",
                              style: TextStyle(
                                color: iconColor,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
