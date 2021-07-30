import 'package:daily_log/MenuBottom.dart';
import 'package:flutter/material.dart';

class DetailValidasePage extends StatelessWidget {
  const DetailValidasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("Staff 1"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: SafeArea(child: ListValidasiPekerjaanPage()),
      bottomSheet: MenuBottom(),
    );
  }
}

class ListValidasiPekerjaanPage extends StatelessWidget {
  const ListValidasiPekerjaanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Card(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Judul Pekerjaan",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text("Keterangan"),
                  Text("Durasi: 01:00"),
                  Row(
                    children: [
                      Text("Validasi"),
                      Switch(value: true, onChanged: (val) => {})
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Judul Pekerjaan",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text("Keterangan"),
                  Text("Durasi: 01:00"),
                  Row(
                    children: [
                      Text("Validasi"),
                      Switch(value: false, onChanged: (val) => {})
                    ],
                  ),
                  Text("Saran"),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Saran",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialButton(
                  onPressed: () => {},
                  child: Text("KEMBALI"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  color: Color(0xFF1A73E9),
                  textColor: Colors.white,
                  height: 40,
                ),
                SizedBox(
                  width: 16,
                ),
                MaterialButton(
                  onPressed: () => {},
                  child: Text("VALIDASI"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  color: Color(0xFF1A73E9),
                  textColor: Colors.white,
                  height: 40,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
