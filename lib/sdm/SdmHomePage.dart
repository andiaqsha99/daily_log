import 'package:daily_log/sdm/DownloadKinerjaPage.dart';
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
              color: Colors.white,
            ))
      ]),
      body: SafeArea(
        child: Expanded(
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
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Color(0xffD93025),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DownloadKinerjaPage()));
                        },
                        icon: Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        iconSize: 72,
                      ),
                      Text("Download laporan",
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
                  color: Color(0xffD93025),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InputPekerjaanPage()));
                        },
                        icon: Icon(
                          Icons.note_add,
                          color: Colors.white,
                        ),
                        iconSize: 72,
                      ),
                      Text("Input Pekerjaan",
                          style: TextStyle(
                            color: Colors.white,
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
