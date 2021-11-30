import 'package:daily_log/BebanKerjaPage.dart';
import 'package:daily_log/DashboardPage.dart';
import 'package:daily_log/KehadiranPage.dart';
import 'package:daily_log/LaporanKinerjaPage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/DurasiHarian.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/Position.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class KinerjaTimStaffPage extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final String idPosition;
  final int idStaff;
  const KinerjaTimStaffPage(
      {Key? key,
      required this.idPosition,
      required this.firstDate,
      required this.lastDate,
      required this.idStaff})
      : super(key: key);

  @override
  _KinerjaTimStaffPageState createState() => _KinerjaTimStaffPageState();
}

class _KinerjaTimStaffPageState extends State<KinerjaTimStaffPage> {
  int totalPekerjaan = 0;
  bool isOneDay = false;

  List<DurasiHarian> listDurasiHarian = [];

  @override
  void initState() {
    super.initState();

    loadDataTotalPekerjaan(widget.firstDate, widget.lastDate);
    loadDurasiHarianTim(widget.firstDate, widget.lastDate);
  }

  loadDataTotalPekerjaan(String firstDate, String endDate) async {
    int count = 0;
    int counter = await ApiService()
        .getValidPekerjaanCount(widget.idStaff, firstDate, endDate);
    count += counter;
    PenggunaResponse penggunaResponse =
        await ApiService().getPenggunaStaff(int.parse(widget.idPosition));
    List<Pengguna> listStaff = penggunaResponse.data;
    listStaff.forEach((element) async {
      counter = await ApiService()
          .getValidPekerjaanCount(element.id, firstDate, endDate);
      count += counter;
      setState(() {
        totalPekerjaan = count;
      });
    });
  }

  loadDurasiHarianTim(String firstDate, String endDate) async {
    listDurasiHarian.clear();
    if (firstDate == endDate) {
      isOneDay = true;
      var durasiResponse = await ApiService().getDurasiHarianTimStaff1Hari(
          widget.idPosition, widget.idStaff, firstDate, endDate);
      setState(() {
        listDurasiHarian = durasiResponse.data;
      });
    } else {
      isOneDay = false;
      var durasiResponse = await ApiService().getDurasiHarianTimStaff(
          widget.idPosition, widget.idStaff, firstDate, endDate);
      setState(() {
        listDurasiHarian = durasiResponse.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Kinerja Tim"),
        actions: [NotificationWidget()],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 56),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              totalPekerjaan == 0
                  ? Center(
                      child: Text("Tidak ada data"),
                    )
                  : Container(
                      height: 150,
                      width: double.infinity,
                      child: LineChartTotalPekerjaan(
                        listData: listDurasiHarian,
                        isOneDay: isOneDay,
                      )),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalPekerjaan.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Total Pekerjaan",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              ListTeam(
                tab: "tim",
                idUser: widget.idStaff,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: MenuBottom(),
    );
  }
}

class ListTeam extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final String tab;
  final int idUser;
  const ListTeam(
      {Key? key,
      required this.tab,
      required this.idUser,
      this.firstDate = '',
      this.lastDate = ''})
      : super(key: key);

  @override
  _ListTeamState createState() => _ListTeamState();
}

class _ListTeamState extends State<ListTeam> {
  late Future<PositionResponse> positionResponse;
  late Future<PenggunaResponse> penggunaResponse;
  List<Position> listPosition = [];

  @override
  void initState() {
    loadStaffData();
    loadPositionData();
    super.initState();
  }

  loadPositionData() async {
    positionResponse = ApiService().getPosition();
    positionResponse.then((value) => listPosition = value.data);
  }

  loadStaffData() async {
    penggunaResponse = ApiService().getPenggunaStaff(widget.idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<PenggunaResponse>(
      future: penggunaResponse,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("No Data"),
          );
        } else if (snapshot.hasData) {
          List<Pengguna> items = snapshot.data!.data;
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemListTim(
                    pengguna: items[index],
                    tab: widget.tab,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate);
              });
        }

        return CircularProgressIndicator();
      },
    ));
  }
}

class ItemListTim extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final Pengguna pengguna;
  final String tab;
  const ItemListTim(
      {Key? key,
      required this.pengguna,
      required this.tab,
      this.firstDate = '',
      this.lastDate = ''})
      : super(key: key);

  @override
  _ItemListTimState createState() => _ItemListTimState();
}

class _ItemListTimState extends State<ItemListTim> {
  bool isExpanded = false;
  bool isAtasan = true;
  late List<Position> filteredList;
  late Future<PenggunaResponse> penggunaResponse;

  @override
  void initState() {
    loadStaffData();
    super.initState();
  }

  loadStaffData() async {
    penggunaResponse = ApiService().getPenggunaStaff(widget.pengguna.id);
  }

  @override
  Widget build(BuildContext context) {
    var positionProvider = Provider.of<PositionProvider>(context);
    var usersProvider = Provider.of<UsersProvider>(context);
    return Column(
      children: [
        Card(
            child: ListTile(
          onTap: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return widget.tab == "tim"
                  ? LaporanKinerjaPage(
                      idUser: widget.pengguna.id,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                    )
                  : widget.tab == "beban kerja"
                      ? BebanKerjaPage(idUser: widget.pengguna.id)
                      : KehadiranPage(idUser: widget.pengguna.id);
            }));
          },
          leading: CircleAvatar(),
          title: widget.pengguna.nip == "000000"
              ? Text(widget.pengguna.username)
              : Text(usersProvider.getUsers(widget.pengguna.nip).name),
          subtitle: widget.pengguna.nip == "000000"
              ? Text(positionProvider
                  .getPosition(widget.pengguna.positionId)
                  .position)
              : Text(usersProvider.getUsers(widget.pengguna.nip).namaJabatan),
        )),
      ],
    );
  }
}
