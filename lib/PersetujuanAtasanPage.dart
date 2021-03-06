import 'package:daily_log/DetailValidasiPage.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/PersetujuanPage.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            bottom: TabBar(
                indicatorColor: Color(0xffba6b6c),
                indicatorWeight: 5.0,
                labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                tabs: [
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
  int idUser = 0;
  String query = '';
  late List<Pengguna> items;
  List<Pengguna> listPengguna = [];
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLoginData();
    loadStaffData();
  }

  loadStaffData() async {
    listStaff = ApiService().getPenggunaStaff(idUser);
    print(idUser);
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idUser = sharedPreferences.getInt("id_user")!;
      loadStaffData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var positionProvider = Provider.of<PositionProvider>(context);
    var usersProvider = Provider.of<UsersProvider>(context);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8),
        child: FutureBuilder<PenggunaResponse>(
          future: listStaff,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              items = snapshot.data!.data;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: Colors.black26),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          listPengguna = items
                              .where(
                                  (element) => element.username.contains(value))
                              .toList();
                        });
                      },
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: 'Cari',
                          border: InputBorder.none),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return DetailValidasePage(
                              staff: _textEditingController.text.isNotEmpty
                                  ? listPengguna[index]
                                  : items[index],
                            );
                          }));
                        },
                        child: Card(
                            elevation: 4,
                            child: Container(
                                padding: EdgeInsets.all(8),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _textEditingController.text.isNotEmpty
                                          ? listPengguna[index].nip == "000000"
                                              ? listPengguna[index].username
                                              : usersProvider
                                                  .getUsers(
                                                      listPengguna[index].nip)
                                                  .name
                                          : items[index].nip == "000000"
                                              ? items[index].username
                                              : usersProvider
                                                  .getUsers(items[index].nip)
                                                  .name,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Text(_textEditingController.text.isNotEmpty
                                        ? listPengguna[index].nip == "000000"
                                            ? positionProvider
                                                .getPosition(listPengguna[index]
                                                    .positionId)
                                                .position
                                            : usersProvider
                                                .getUsers(
                                                    listPengguna[index].nip)
                                                .namaJabatan
                                        : items[index].nip == "000000"
                                            ? positionProvider
                                                .getPosition(
                                                    items[index].positionId)
                                                .position
                                            : usersProvider
                                                .getUsers(items[index].nip)
                                                .namaJabatan)
                                  ],
                                ))),
                      );
                    },
                    itemCount: _textEditingController.text.isNotEmpty
                        ? listPengguna.length
                        : items.length,
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error"),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
