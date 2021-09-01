import 'package:daily_log/PersetujuanPage.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final List<SubPekerjaan> listSubPekerjaan;
  const NotificationPage({Key? key, required this.listSubPekerjaan})
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
                  return NotificationItem(
                    subPekerjaan: widget.listSubPekerjaan[index],
                  );
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
          child: Text("Pekerjaan ${subPekerjaan.nama} ditolak"),
        ),
      ),
    );
  }
}
