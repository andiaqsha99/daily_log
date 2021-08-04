import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilStatus extends StatefulWidget {
  const ProfilStatus({Key? key}) : super(key: key);

  @override
  _ProfilStatusState createState() => _ProfilStatusState();
}

class _ProfilStatusState extends State<ProfilStatus> {
  String username = " ";

  @override
  void initState() {
    super.initState();
    getLoginData();
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      username = sharedPreferences.getString("username")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Color(0xFF5A9EFF),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              maxRadius: 36,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang,",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    username,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "Jabatan",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                ],
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(
                "0%",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }
}
