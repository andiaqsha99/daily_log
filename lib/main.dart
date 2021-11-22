import 'package:daily_log/LoginWrapper.dart';
import 'package:daily_log/model/NotifProvider.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              appBarTheme: AppBarTheme(color: Color(0xffB31412)),
              fontFamily: 'Helvetica',
              // primarySwatch: Colors.blue,
              primaryColor: Color(0xffB31412)),
          home: LoginWrapper()),
    );
  }
}
