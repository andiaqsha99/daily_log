import 'dart:isolate';
import 'dart:ui';

import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DownloadKinerjaPage extends StatefulWidget {
  const DownloadKinerjaPage({Key? key}) : super(key: key);

  @override
  State<DownloadKinerjaPage> createState() => _DownloadKinerjaPageState();
}

class _DownloadKinerjaPageState extends State<DownloadKinerjaPage> {
  DateTimeRange? dateTimeRange;
  int totalPekerjaan = 0;
  bool isShowList = false;

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _untilDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download laporan pekerjaan"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Card(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Tanggal"),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: GestureDetector(
                            onTap: () {
                              pickDateRange(context);
                            },
                            child: TextFormField(
                              enabled: false,
                              controller: _fromDateController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8),
                                  fillColor: Color(0xFFE3F5FF),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text("to"),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: GestureDetector(
                            onTap: () {
                              pickDateRange(context);
                            },
                            child: TextFormField(
                              enabled: false,
                              controller: _untilDateController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8),
                                  fillColor: Color(0xFFE3F5FF),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        isShowList = true;
                      });
                    },
                    height: 48,
                    minWidth: 96,
                    color: Colors.blue,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "TAMPILKAN",
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
          ),
          isShowList
              ? ListTeam(
                  idUser: 2,
                  firstDate: _fromDateController.text,
                  lastDate: _untilDateController.text,
                )
              : Center(child: Text("Masukkan tanggal terlebih dahulu")),
        ],
      )),
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
  final int idUser;
  final String firstDate;
  final String lastDate;
  const ListTeam(
      {Key? key,
      required this.idUser,
      required this.firstDate,
      required this.lastDate})
      : super(key: key);

  @override
  _ListTeamState createState() => _ListTeamState();
}

class _ListTeamState extends State<ListTeam> {
  late Future<PositionResponse> positionResponse;
  late Future<PenggunaResponse> penggunaResponse;

  @override
  void initState() {
    loadStaffData();
    super.initState();
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
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                );
              });
        }

        return CircularProgressIndicator();
      },
    ));
  }
}

class ItemListTim extends StatefulWidget {
  final Pengguna pengguna;
  final String firstDate;
  final String lastDate;
  const ItemListTim(
      {Key? key,
      required this.pengguna,
      required this.firstDate,
      required this.lastDate})
      : super(key: key);

  @override
  _ItemListTimState createState() => _ItemListTimState();
}

class _ItemListTimState extends State<ItemListTim> {
  bool isExpanded = false;
  bool isAtasan = true;
  late Future<PenggunaResponse> penggunaResponse;

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    loadStaffData();
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
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
          leading: widget.pengguna.foto == null
              ? CircleAvatar()
              : CircleAvatar(
                  backgroundImage: NetworkImage(
                      "${ApiService().storageUrl}${widget.pengguna.foto}"),
                ),
          title: widget.pengguna.nip == "000000"
              ? Text(widget.pengguna.username)
              : Text(usersProvider.getUsers(widget.pengguna.nip).name),
          subtitle: widget.pengguna.nip == "000000"
              ? Text(positionProvider
                  .getPosition(widget.pengguna.positionId)
                  .position)
              : Text(usersProvider.getUsers(widget.pengguna.nip).namaJabatan),
          trailing: widget.pengguna.jabatan == "atasan"
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        var fdate =
                            DateFormat("dd/MM/yyyy").parse(widget.firstDate);
                        var firstDate = DateFormat("yyyy-MM-dd").format(fdate);
                        var ldate =
                            DateFormat("dd/MM/yyyy").parse(widget.lastDate);
                        var lastDate = DateFormat("yyyy-MM-dd").format(ldate);
                        var status = await Permission.storage.request();
                        if (status.isGranted) {
                          final baseStorage =
                              await getExternalStorageDirectory();
                          await FlutterDownloader.enqueue(
                            url:
                                '${ApiService().baseUrl}/pengguna/${widget.pengguna.id}/persetujuan/subpekerjaan/valid/$firstDate/$lastDate/download',
                            savedDir: baseStorage!.path,
                            showNotification:
                                true, // show download progress in status bar (for Android)
                            openFileFromNotification:
                                true, // click on notification to open downloaded file (for Android)
                          );
                        }
                      },
                      child: Icon(Icons.download),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: isExpanded
                          ? Icon(Icons.keyboard_arrow_up)
                          : Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () async {
                    var fdate =
                        DateFormat("dd/MM/yyyy").parse(widget.firstDate);
                    var firstDate = DateFormat("yyyy-MM-dd").format(fdate);
                    var ldate = DateFormat("dd/MM/yyyy").parse(widget.lastDate);
                    var lastDate = DateFormat("yyyy-MM-dd").format(ldate);
                    var status = await Permission.storage.request();
                    if (status.isGranted) {
                      final baseStorage = await getExternalStorageDirectory();
                      await FlutterDownloader.enqueue(
                        url:
                            '${ApiService().baseUrl}/pengguna/${widget.pengguna.id}/persetujuan/subpekerjaan/valid/$firstDate/$lastDate/download',
                        savedDir: baseStorage!.path,
                        showNotification:
                            true, // show download progress in status bar (for Android)
                        openFileFromNotification:
                            true, // click on notification to open downloaded file (for Android)
                      );
                    }
                  },
                  child: Icon(Icons.download),
                ),
        )),
        if (isExpanded)
          Container(
              padding: EdgeInsets.only(left: 10),
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
                            firstDate: widget.firstDate,
                            lastDate: widget.lastDate,
                          );
                        });
                  }

                  return CircularProgressIndicator();
                },
              ))
      ],
    );
  }
}
