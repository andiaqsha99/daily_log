import 'package:daily_log/DetailValidasiPage.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/PersetujuanPage.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MenuBottom.dart';

class PersetujuanAtasanPage extends StatelessWidget {
  final int intialIndex;
  final int? idSubPekerjaan;
  const PersetujuanAtasanPage(
      {Key? key, this.intialIndex = 0, this.idSubPekerjaan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Persetujuan"),
            bottom: TabBar(tabs: [
              Tab(
                text: "VALIDASI",
              ),
              Tab(
                text: "MENUNGGU",
              ),
              Tab(
                text: "DITOLAK",
              )
            ]),
            actions: [NotificationWidget()],
          ),
          body: TabBarView(children: [
            ListValidasiPage(),
            MenungguPage(),
            DitolakPage(
              idSubPekerjaan: this.idSubPekerjaan,
            )
          ]),
          bottomSheet: MenuBottom(),
        ));
  }
}

class ListValidasiPage extends StatefulWidget {
  const ListValidasiPage({Key? key}) : super(key: key);

  @override
  _ListValidasiPageState createState() => _ListValidasiPageState();
}

class _ListValidasiPageState extends State<ListValidasiPage> {
  late Future<PenggunaResponse> listStaff;
  int idPosition = 0;

  @override
  void initState() {
    super.initState();
    getLoginData();
    loadStaffData();
  }

  loadStaffData() async {
    listStaff = ApiService().getPenggunaStaff(idPosition);
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idPosition = sharedPreferences.getInt("position_id")!;
      loadStaffData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Container(
        padding: EdgeInsets.all(8),
        child: FutureBuilder<PenggunaResponse>(
          future: listStaff,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Pengguna> items = snapshot.data!.data;
              return ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return DetailValidasePage(
                          staff: items[index],
                        );
                      }));
                    },
                    child: Card(
                        child: Container(
                            padding: EdgeInsets.all(8),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  items[index].username,
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(items[index].jabatan)
                              ],
                            ))),
                  );
                },
                itemCount: items.length,
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error"),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    ]);
  }
}
