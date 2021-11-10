import 'package:daily_log/HomePage.dart';
import 'package:daily_log/LoginWrapper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuBottom extends StatelessWidget {
  const MenuBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () => {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => false)
                  },
              icon: Icon(Icons.home)),
          IconButton(
              onPressed: () async {
                final sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.setBool("isLogin", false);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginWrapper()),
                    (route) => false);
              },
              icon: Icon(Icons.logout))
        ],
      ),
    );
  }
}
