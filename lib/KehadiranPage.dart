import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/Presence.dart';
import 'package:daily_log/model/PresenceResponse.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class KehadiranPage extends StatefulWidget {
  final int idUser;
  const KehadiranPage({Key? key, required this.idUser}) : super(key: key);

  @override
  _KehadiranPageState createState() => _KehadiranPageState();
}

class _KehadiranPageState extends State<KehadiranPage> {
  late Future<PresenceResponse> presenceResponse;
  List<Presence> listPresence = [];
  String selectedDate = '';
  var now = new DateTime.now();
  Pengguna? _pengguna;

  @override
  void initState() {
    super.initState();

    String thisMonth = DateFormat("MMMM yyyy").format(now);
    selectedDate = thisMonth;

    DateTime firstDate = DateTime(now.year, now.month, 1);

    loadPresenceSatuBulan(firstDate);
    loadDataPengguna();
  }

  loadPresenceSatuBulan(DateTime date) {
    // Find the last day of the month.
    var lastDayDateTime = (date.month < 12)
        ? new DateTime(date.year, date.month + 1, 0)
        : new DateTime(date.year + 1, 1, 0);
    print(lastDayDateTime);
    String firstDate = DateFormat("yyyy-MM-dd").format(date);
    String endDate = DateFormat("yyyy-MM-dd").format(lastDayDateTime);

    presenceResponse =
        ApiService().getUserPresenceByDate(widget.idUser, firstDate, endDate);
  }

  loadDataPengguna() async {
    var pengguna = await ApiService().getPenggunaById(widget.idUser);
    setState(() {
      _pengguna = pengguna;
    });
  }

  @override
  Widget build(BuildContext context) {
    var usersProvider = Provider.of<UsersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: _pengguna == null
            ? Text("Kehadiran")
            : _pengguna!.nip == "000000"
                ? Text("Kehadiran")
                : Text(usersProvider.getUsers(_pengguna!.nip).name),
        actions: [NotificationWidget()],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      onPressed: () {
                        showMonthPicker(
                                context: context,
                                initialDate:
                                    DateFormat("MMMM yyyy").parse(selectedDate))
                            .then((date) {
                          if (date != null) {
                            setState(() {
                              print(date);
                              String thisMonth =
                                  DateFormat("MMMM yyyy").format(date);
                              selectedDate = thisMonth;
                              print(selectedDate);
                              loadPresenceSatuBulan(date);
                            });
                          }
                        });
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          selectedDate,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.black),
                        ),
                      ))),
              SizedBox(
                height: 8,
              ),
              FutureBuilder<PresenceResponse>(
                  future: presenceResponse,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      listPresence = snapshot.data!.data;
                      if (listPresence.length == 0) {
                        return Text("Tidak ada data");
                      }
                      List<DataRow> listRow = [];
                      listPresence.forEach((presence) {
                        int duration = 0;
                        if (presence.checkOutTime != null) {
                          var dateFormat = DateFormat("HH:mm:ss");
                          DateTime first =
                              dateFormat.parse(presence.checkInTime);
                          DateTime second =
                              dateFormat.parse(presence.checkOutTime!);
                          duration = second.difference(first).inMinutes;
                        }
                        listRow.add(DataRow(cells: [
                          DataCell(Center(child: Text(presence.date))),
                          DataCell(Center(child: Text(presence.checkInTime))),
                          DataCell(Center(
                            child: Text(presence.checkOutTime == null
                                ? "-"
                                : presence.checkOutTime!),
                          )),
                          DataCell(Center(
                              child: Text((() {
                            if (duration < 10) {
                              return "00.0$duration";
                            } else if (duration > 59) {
                              int jam = duration ~/ 60;
                              int menit = duration % 60;
                              if (menit < 10) {
                                return "$jam.0$menit";
                              }
                              return "$jam.$menit";
                            } else {
                              return "00.$duration";
                            }
                          }())))),
                        ]));
                      });
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            columnSpacing: 32.0,
                            columns: [
                              DataColumn(label: Text("Tanggal")),
                              DataColumn(label: Text("Check In")),
                              DataColumn(label: Text("Check Out")),
                              DataColumn(label: Text("Durasi(jam)"))
                            ],
                            rows: listRow),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  })
            ],
          ),
        ),
      ),
      bottomNavigationBar: MenuBottom(),
    );
  }
}
