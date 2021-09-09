import 'package:daily_log/DetailValidasiPage.dart';
import 'package:daily_log/PersetujuanPage.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final List<SubPekerjaan> listSubPekerjaan;
  final List<Pengguna> listPengguna;
  const NotificationPage(
      {Key? key, required this.listSubPekerjaan, required this.listPengguna})
      : super(key: key);

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
            ListView.builder(
                shrinkWrap: true,
                itemCount: widget.listSubPekerjaan.length,
                itemBuilder: (context, index) {
                  if (widget.listSubPekerjaan[index].status == 'submit') {
                    var pengguna = widget.listPengguna.where((element) =>
                        element.id == widget.listSubPekerjaan[index].idUser);
                    return NotificationItemSubmit(
                      subPekerjaan: widget.listSubPekerjaan[index],
                      pengguna: pengguna.first,
                    );
                  } else {
                    return NotificationItem(
                      subPekerjaan: widget.listSubPekerjaan[index],
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final SubPekerjaan subPekerjaan;
  const NotificationItem({Key? key, required this.subPekerjaan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return PersetujuanPage(
            intialIndex: 1,
            subPekerjaan: subPekerjaan,
          );
        }));
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          child: RichText(
              text: TextSpan(
                  text: "Pekerjaan ",
                  style: TextStyle(color: Colors.black),
                  children: [
                TextSpan(text: "${subPekerjaan.nama} telah di "),
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
  final SubPekerjaan subPekerjaan;
  const NotificationItemSubmit(
      {Key? key, required this.subPekerjaan, required this.pengguna})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return DetailValidasePage(staff: pengguna);
        }));
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          child: RichText(
              text: TextSpan(
                  text: "Pekerjaan ",
                  style: TextStyle(color: Colors.black),
                  children: [
                TextSpan(text: "${subPekerjaan.nama} telah di "),
                TextSpan(
                    text: "submit",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: " oleh ${pengguna.username}"),
              ])),
        ),
      ),
    );
  }
}
