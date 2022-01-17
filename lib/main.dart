import 'package:daily_log/LoginWrapper.dart';
import 'package:daily_log/model/NotifProvider.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:daily_log/model/SettingProvider.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotifProvider()),
        ChangeNotifierProvider(create: (_) => NotifCounterProvider()),
        ChangeNotifierProvider(create: (_) => PositionProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              // appBarTheme: AppBarTheme(color: Color(0xffB31412)),
              // appBarTheme: AppBarTheme(color: Color(0xffce93d8)),
              appBarTheme: AppBarTheme(
                  color: Color(0xffef9a9a), foregroundColor: Colors.black),
              // appBarTheme: AppBarTheme(color: Color(0xffe28c38)),
              fontFamily: 'Helvetica',
              buttonTheme: ButtonThemeData(buttonColor: Color(0xffef9a9a)),
              // primarySwatch: Colors.blue,
              // primaryColor: Color(0xffB31412)),
              // primaryColor: Color(0xffce93d8)),
              primaryColor: Color(0xffef9a9a)),
          // primaryColor: Color(0xffe28c38)),
          home: LoginWrapper()),
    );
  }
}
