import 'package:daily_log/DetailValidasiPage.dart';
import 'package:daily_log/PersetujuanPage.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Notif.dart';
import 'package:daily_log/model/NotifProvider.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  final List<Notif> listNotif;
  const NotificationPage({Key? key, required this.listNotif}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifikasi"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            widget.listNotif.length == 0
                ? Center(child: Text("Tidak ada pemberitahuan"))
                : GroupedListView<Notif, String>(
                    shrinkWrap: true,
                    elements: widget.listNotif,
                    groupBy: (element) {
                      return element.date;
                    },
                    groupSeparatorBuilder: (groupBy) {
                      String dateFormat = DateFormat("dd MMMM yyyy")
                          .format(DateTime.parse(groupBy));
                      return Text(dateFormat);
                    },
                    itemBuilder: (context, notif) {
                      if (notif.status == 'submit') {
                        return FutureBuilder<Pengguna>(
                            future: ApiService().getPenggunaById(notif.sender!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return NotificationItemSubmit(
                                  notif: notif,
                                  pengguna: snapshot.data!,
                                );
                              } else {
                                return SizedBox();
                              }
                            });
                      } else {
                        return NotificationItem(
                          notif: notif,
                        );
                      }
                    },
                  )
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final Notif notif;
  const NotificationItem({Key? key, required this.notif}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        ApiService().updateNotificationRead(notif.id);
        Provider.of<NotifCounterProvider>(context, listen: false).onChange();
        Provider.of<NotifProvider>(context, listen: false).onChange();
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return PersetujuanPage(
            intialIndex: 1,
            idSubPekerjaan: notif.idPekerjaan,
          );
        }));
      },
      child: Card(
        color: notif.isRead == 0 ? Color(0xFFEDFEFF) : Color(0xFFFFFFFF),
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          child: RichText(
              text: TextSpan(
                  text: "Pekerjaan ",
                  style: TextStyle(color: Colors.black),
                  children: [
                TextSpan(text: "${notif.nama} telah di "),
                TextSpan(
                    text: "tolak",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ])),
        ),
      ),
    );
  }
}

class NotificationItemSubmit extends StatelessWidget {
  final Pengguna pengguna;
  final Notif notif;
  const NotificationItemSubmit(
      {Key? key, required this.notif, required this.pengguna})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var usersProvider = Provider.of<UsersProvider>(context);
    return GestureDetector(
      onTap: () {
        ApiService().updateNotificationRead(notif.id);
        Provider.of<NotifCounterProvider>(context, listen: false).onChange();
        Provider.of<NotifProvider>(context, listen: false).onChange();
        ApiService().getSubpekerjaanById(notif.subPekerjaanId).then((value) {
          if (value.status == 'submit') {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return DetailValidasePage(staff: pengguna);
            }));
          }
        });
      },
      child: Card(
        color: notif.isRead == 0 ? Color(0xFFEDFEFF) : Color(0xFFFFFFFF),
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          child: RichText(
              text: TextSpan(
                  text: "Pekerjaan ",
                  style: TextStyle(color: Colors.black),
                  children: [
                TextSpan(text: "${notif.nama} telah di "),
                TextSpan(
                    text: "submit",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        " oleh ${usersProvider.getUsers(this.pengguna.nip).name}"),
              ])),
        ),
      ),
    );
  }
}
