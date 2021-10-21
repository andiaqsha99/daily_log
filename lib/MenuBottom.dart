import 'package:daily_log/HomePage.dart';
import 'package:daily_log/LoginWrapper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuBottom extends StatelessWidget {
  const MenuBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () => {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => false)
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => HomePage()))
                  },
              icon: Icon(Icons.home)),
          IconButton(
              onPressed: () async {
                final sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.setBool("isLogin", false);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginWrapper()),
                    (route) => false);
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) => LoginWrapper()));
              },
              icon: Icon(Icons.logout))
        ],
      ),
    );
  }
}
