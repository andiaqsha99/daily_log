import 'package:daily_log/MenuBottom.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatelessWidget {
  const QrCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("QR Code"),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text("CHECK IN"),
              ),
              Tab(
                child: Text("CHECK OUT"),
              )
            ],
          ),
        ),
        body: TabBarView(children: [
          Container(
            child: Center(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImage(
                      data: 'http://192.168.43.126:8000/api/arrival/checkin',
                      size: 200,
                    ),
                    Text(
                      "Check In",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Center(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImage(
                      data: 'http://192.168.43.126:8000/api/arrival/checkout',
                      size: 200,
                    ),
                    Text(
                      "Check Out",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),
        ]),
        bottomSheet: MenuBottom(),
      ),
    );
  }
}
