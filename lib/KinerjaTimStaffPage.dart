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
import 'package:daily_log/model/PositionResponse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KinerjaTimStaffPage extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final int idPosition;
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
  String dropdownValue = '1 Bulan';
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isOneDay = false;

  List<DurasiHarian> listDurasiHarian = [];

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

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
        await ApiService().getPenggunaStaff(widget.idPosition);
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
                idPosition: widget.idPosition,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: MenuBottom(),
    );
  }

  Future pickDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 24 * 2)));
    final newDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: dateTimeRange ?? initialDateRange);

    if (newDateRange == null) {
      return;
    } else {
      setState(() {
        dateTimeRange = newDateRange;
        _untilDateController.text = getUntilDate();
        _fromDateController.text = getFromDate();
      });
    }
  }

  String getFromDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.start);
    }
  }

  String getUntilDate() {
    if (dateTimeRange == null) {
      return '';
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTimeRange!.end);
    }
  }
}

class ListTeam extends StatefulWidget {
  final String firstDate;
  final String lastDate;
  final String tab;
  final int idPosition;
  const ListTeam(
      {Key? key,
      required this.tab,
      required this.idPosition,
      this.firstDate = '',
      this.lastDate = ''})
      : super(key: key);

  @override
  _ListTeamState createState() => _ListTeamState();
}

class _ListTeamState extends State<ListTeam> {
  late Future<PositionResponse> positionResponse;

  @override
  void initState() {
    positionResponse = ApiService().getPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<PositionResponse>(
      future: positionResponse,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("No Data"),
          );
        } else if (snapshot.hasData) {
          List<Position> items = snapshot.data!.data;
          var listStaf = items
              .where((element) =>
                  element.parentId == widget.idPosition ||
                  element.id == widget.idPosition)
              .toList();
          var filteredList =
              items.where((element) => element.level > 1).toList();
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: listStaf.length,
              itemBuilder: (context, index) {
                return ItemListTim(
                    position: listStaf[index],
                    listPosition: filteredList,
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
  final Position position;
  final List<Position> listPosition;
  final String tab;
  const ItemListTim(
      {Key? key,
      required this.position,
      required this.listPosition,
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
  late List<Position> listStaf;

  @override
  void initState() {
    filteredList = widget.listPosition
        .where((element) => element.level > widget.position.level)
        .toList();
    listStaf = filteredList
        .where((element) => element.parentId == widget.position.id)
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            child: ListTile(
          onTap: () async {
            Pengguna pengguna =
                await ApiService().getPenggunaByPosition(widget.position.id);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return widget.tab == "tim"
                  ? LaporanKinerjaPage(idUser: pengguna.id)
                  : widget.tab == "beban kerja"
                      ? BebanKerjaPage(idUser: pengguna.id)
                      : KehadiranPage(idUser: pengguna.id);
            }));
          },
          leading: CircleAvatar(),
          title: Text(widget.position.position),
          subtitle: Text(widget.position.position),
        )),
      ],
    );
  }
}
