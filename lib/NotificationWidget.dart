import 'package:badges/badges.dart';
import 'package:daily_log/NotificationPage.dart';
import 'package:daily_log/model/NotifProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotifProvider>(builder: (_, notifProvider, ch) {
      return Badge(
        position: BadgePosition.topEnd(end: 1, top: 2),
        showBadge: true,
        badgeContent: Text(notifProvider.counter.toString()),
        child: IconButton(
            onPressed: () => {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return NotificationPage(
                        listSubPekerjaan: notifProvider.listSubPekerjaan,
                        listPengguna: notifProvider.listPengguna);
                  }))
                },
            icon: Icon(Icons.notifications)),
      );
    });
  }
}
