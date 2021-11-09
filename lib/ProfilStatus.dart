import 'package:daily_log/model/PositionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilStatus extends StatefulWidget {
  const ProfilStatus({Key? key}) : super(key: key);

  @override
  _ProfilStatusState createState() => _ProfilStatusState();
}

class _ProfilStatusState extends State<ProfilStatus> {
  String username = " ";
  int idPosition = 0;
  late PositionProvider positionProvider;

  @override
  void initState() {
    super.initState();
    getLoginData();
    positionProvider = Provider.of<PositionProvider>(context, listen: false);
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      username = sharedPreferences.getString("username")!;
      idPosition = sharedPreferences.getInt("position_id")!;
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
        ],
      ),
    );
  }
}
