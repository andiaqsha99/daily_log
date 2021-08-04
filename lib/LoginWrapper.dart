import 'package:daily_log/HomePage.dart';
import 'package:daily_log/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWrapper extends StatefulWidget {
  const LoginWrapper({Key? key}) : super(key: key);

  @override
  _LoginWrapperState createState() => _LoginWrapperState();
}

class _LoginWrapperState extends State<LoginWrapper> {
  @override
  void initState() {
    super.initState();
    checkLoginData();
  }

  checkLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool isLogin;
    isLogin = sharedPreferences.getBool("isLogin") ?? false;

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return isLogin ? HomePage() : LoginPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
