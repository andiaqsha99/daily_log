import 'package:daily_log/DetailValidasiPage.dart';
import 'package:daily_log/HomePage.dart';
import 'package:daily_log/LaporanKinerjaPage.dart';
import 'package:daily_log/LoginPage.dart';
import 'package:daily_log/PekerjaanHarianPage.dart';
import 'package:daily_log/PersetujuanAtasanPage.dart';
import 'package:daily_log/PersetujuanPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DetailValidasePage());
  }
}
