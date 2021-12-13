import 'package:badges/badges.dart';
import 'package:daily_log/NotificationPage.dart';
import 'package:daily_log/model/NotifProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var notifProvider = Provider.of<NotifProvider>(context);
    return Consumer<NotifCounterProvider>(builder: (context, provider, child) {
      return Badge(
        position: BadgePosition.topEnd(end: 1, top: 2),
        showBadge: provider.counter == 0 ? false : true,
        badgeContent: Text(provider.counter.toString()),
        child: IconButton(
            onPressed: () => {
                  provider.onChange(),
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return NotificationPage(listNotif: notifProvider.listNotif);
                  }))
                },
            icon: Icon(Icons.notifications)),
      );
    });
  }
}
