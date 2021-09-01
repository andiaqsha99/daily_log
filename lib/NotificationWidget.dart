import 'package:badges/badges.dart';
import 'package:daily_log/NotificationPage.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/SubPekerjaan.dart';
import 'package:daily_log/model/SubPekerjaanResponse.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({Key? key}) : super(key: key);

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  String jabatan = " ";
  int idUser = 0;
  int idPosition = 0;
  List<SubPekerjaan> listSubPekerjaan = [];

  @override
  void initState() {
    super.initState();
    getLoginData();
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      jabatan = sharedPreferences.getString("jabatan")!;
      idUser = sharedPreferences.getInt("id_user")!;
      idPosition = sharedPreferences.getInt("position_id")!;
      getListRejectSubPekerjaan();
    });
  }

  getListRejectSubPekerjaan() async {
    final pekerjaanResponse = await ApiService().getPekerjaan(idUser);

    pekerjaanResponse.data.forEach((element) async {
      final subPekerjaanResponse =
          await ApiService().getRejectPekerjaan(element.id);

      setState(() {
        listSubPekerjaan.addAll(subPekerjaanResponse.data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Badge(
      position: BadgePosition.topEnd(end: 1, top: 2),
      showBadge: listSubPekerjaan.length < 1 ? false : true,
      badgeContent: Text(listSubPekerjaan.length.toString()),
      child: IconButton(
          onPressed: () => {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NotificationPage(
                    listSubPekerjaan: this.listSubPekerjaan,
                  );
                }))
              },
          icon: Icon(Icons.notifications)),
    );
  }
}
