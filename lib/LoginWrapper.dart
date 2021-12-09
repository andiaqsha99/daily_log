import 'package:daily_log/HomePage.dart';
import 'package:daily_log/LoginPage.dart';
import 'package:daily_log/model/NotifProvider.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/SettingProvider.dart';

class LoginWrapper extends StatefulWidget {
  const LoginWrapper({Key? key}) : super(key: key);

  @override
  _LoginWrapperState createState() => _LoginWrapperState();
}

class _LoginWrapperState extends State<LoginWrapper> {
  String jabatan = " ";
  int idUser = 0;
  int idPosition = 0;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    checkLoginData();
  }

  checkLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isLogin = sharedPreferences.getBool("isLogin") ?? false;
      jabatan = sharedPreferences.getString("jabatan") ?? " ";
      idUser = sharedPreferences.getInt("id_user") ?? 0;
      idPosition = sharedPreferences.getInt("position_id") ?? 0;

      var provider = Provider.of<NotifProvider>(context, listen: false);
      provider.addListNotif(idUser);

      var providerCounter =
          Provider.of<NotifCounterProvider>(context, listen: false);
      providerCounter.addListNotif(idUser);

      var positionProvider =
          Provider.of<PositionProvider>(context, listen: false);
      positionProvider.setListPosition();

      var usersProvider = Provider.of<UsersProvider>(context, listen: false);
      usersProvider.setListUsers();

      var settingProvider =
          Provider.of<SettingProvider>(context, listen: false);
      settingProvider.setNumBackdate();

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return isLogin ? HomePage() : LoginPage();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
