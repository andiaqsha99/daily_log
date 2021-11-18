import 'package:daily_log/UploadFotoPage.dart';
import 'package:daily_log/api/ApiService.dart';
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
  String position = "jabatan";
  int idUser = 0;
  String? foto;

  @override
  void initState() {
    super.initState();
    getLoginData();
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      username = sharedPreferences.getString("username")!;
      idPosition = sharedPreferences.getInt("position_id")!;
      idUser = sharedPreferences.getInt("id_user")!;
      position = sharedPreferences.getString("position")!;
      foto = sharedPreferences.getString("foto");
      print(foto);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      // color: Color(0xFF5A9EFF),
      color: Color(0xffD93025),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return UploadFotoPage(
                    idUser: idUser,
                  );
                })).then((value) {
                  setState(() {
                    getLoginData();
                  });
                });
              },
              child: foto == null
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: 36,
                    )
                  : CircleAvatar(
                      backgroundImage:
                          NetworkImage("${ApiService().storageUrl}$foto"),
                      maxRadius: 36,
                    ),
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
                    position,
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
