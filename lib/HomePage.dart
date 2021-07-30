import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SAKIRA"),
        actions: [
          IconButton(onPressed: () => {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: SafeArea(child: MenuPage()),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ProfilStatus(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Column(
                children: [
                  Card(
                    color: Color(0xFFB0D8FD),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.desktop_windows),
                      iconSize: 56,
                    ),
                  ),
                  Text("Pekerjaan Harian")
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Card(
                    color: Color(0xFFB0D8FD),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.assignment_ind),
                      iconSize: 56,
                    ),
                  ),
                  Text("Laporan Kinerja")
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Card(
                    color: Color(0xFFB0D8FD),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.assignment_turned_in),
                      iconSize: 56,
                    ),
                  ),
                  Text("Persetujuan")
                ],
              ),
            ),
          ],
        ),
        MenuBottom()
      ],
    );
  }
}
