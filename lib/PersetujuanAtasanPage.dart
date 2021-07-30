import 'package:flutter/material.dart';

import 'MenuBottom.dart';

class PersetujuanAtasanPage extends StatelessWidget {
  const PersetujuanAtasanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Persetujuan"),
            bottom: TabBar(tabs: [
              Tab(
                text: "VALIDASI",
              ),
              Tab(
                text: "MENUNGGU",
              ),
              Tab(
                text: "DITOLAK",
              )
            ]),
            actions: [
              IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
            ],
          ),
          body: TabBarView(
              children: [ListValidasiPage(), MenungguPage(), DitolakPage()]),
          bottomSheet: MenuBottom(),
        ));
  }
}

class MenungguPage extends StatelessWidget {
  const MenungguPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pekerjaan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Text("Kategori Pekerjaan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            PekerjaanMenungguCard(),
            Text("Kategori Pekerjaan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            PekerjaanMenungguCard(),
            Text("Kategori Pekerjaan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            PekerjaanMenungguCard(),
            Text("Kategori Pekerjaan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            PekerjaanMenungguCard(),
            Text("Kategori Pekerjaan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            PekerjaanMenungguCard(),
          ],
        ),
      ),
    );
  }
}

class PekerjaanMenungguCard extends StatelessWidget {
  const PekerjaanMenungguCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Detail Pekerjaan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "29/07/2021",
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          "Durasi: 01:00",
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          "Keterangan",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            MaterialButton(
              onPressed: () => {},
              child: Text("EDIT"),
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
              child: Text("DELETE"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: Color(0xFFEB5757),
              textColor: Colors.white,
              height: 40,
            )
          ],
        )
      ]),
    ));
  }
}

class DitolakPage extends StatelessWidget {
  const DitolakPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pekerjaan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Text("Kategori Pekerjaan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          PekerjaanDitolakCard(),
          Text("Kategori Pekerjaan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          PekerjaanDitolakCard(),
          Text("Kategori Pekerjaan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          PekerjaanDitolakCard(),
        ],
      ),
    );
  }
}

class PekerjaanDitolakCard extends StatelessWidget {
  const PekerjaanDitolakCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Detail Pekerjaan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "29/07/2021",
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          "Durasi: 01:00",
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          "Keterangan",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            MaterialButton(
              onPressed: () => {},
              child: Text("EDIT"),
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
              child: Text("DELETE"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: Color(0xFFEB5757),
              textColor: Colors.white,
              height: 40,
            ),
            SizedBox(
              width: 16,
            ),
            MaterialButton(
              onPressed: () => {},
              child: Text("SUBMIT"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: Color(0xFF1A73E9),
              textColor: Colors.white,
              height: 40,
            ),
          ],
        )
      ]),
    ));
  }
}

class ListValidasiPage extends StatelessWidget {
  const ListValidasiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var items = List<String>.generate(7, (index) => "Staff $index");
    return Container(
      padding: EdgeInsets.all(8),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
              child: Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index],
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Jabatan")
                    ],
                  )));
        },
        itemCount: items.length,
      ),
    );
  }
}
