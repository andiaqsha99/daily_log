import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:daily_log/model/PenggunaResponse.dart';
import 'package:daily_log/model/PositionProvider.dart';
import 'package:daily_log/model/PositionResponse.dart';
import 'package:daily_log/model/UsersProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DetailInputPekerjaanPage.dart';

class InputPekerjaanPage extends StatefulWidget {
  const InputPekerjaanPage({Key? key}) : super(key: key);

  @override
  _InputPekerjaanPageState createState() => _InputPekerjaanPageState();
}

class _InputPekerjaanPageState extends State<InputPekerjaanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input pekerjaan"),
      ),
      body: SingleChildScrollView(
        child: ListTeam(idUser: 2),
      ),
    );
  }
}

class ListTeam extends StatefulWidget {
  final int idUser;
  const ListTeam({
    Key? key,
    required this.idUser,
  }) : super(key: key);

  @override
  _ListTeamState createState() => _ListTeamState();
}

class _ListTeamState extends State<ListTeam> {
  late Future<PositionResponse> positionResponse;
  late Future<PenggunaResponse> penggunaResponse;

  @override
  void initState() {
    loadStaffData();
    super.initState();
  }

  loadStaffData() async {
    penggunaResponse = ApiService().getPenggunaStaff(widget.idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<PenggunaResponse>(
      future: penggunaResponse,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("No Data"),
          );
        } else if (snapshot.hasData) {
          List<Pengguna> items = snapshot.data!.data;
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemListTim(
                  pengguna: items[index],
                );
              });
        }

        return CircularProgressIndicator();
      },
    ));
  }
}

class ItemListTim extends StatefulWidget {
  final Pengguna pengguna;
  const ItemListTim({
    Key? key,
    required this.pengguna,
  }) : super(key: key);

  @override
  _ItemListTimState createState() => _ItemListTimState();
}

class _ItemListTimState extends State<ItemListTim> {
  bool isExpanded = false;
  bool isAtasan = true;
  late Future<PenggunaResponse> penggunaResponse;

  @override
  void initState() {
    loadStaffData();
    super.initState();
  }

  loadStaffData() async {
    penggunaResponse = ApiService().getPenggunaStaff(widget.pengguna.id);
  }

  @override
  Widget build(BuildContext context) {
    var positionProvider = Provider.of<PositionProvider>(context);
    var usersProvider = Provider.of<UsersProvider>(context);
    return Column(
      children: [
        Card(
            child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailInputPekerjaanPage(
                                pengguna: widget.pengguna,
                              )));
                },
                leading: widget.pengguna.foto == null
                    ? CircleAvatar()
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            "${ApiService().storageUrl}${widget.pengguna.foto}"),
                      ),
                title: widget.pengguna.nip == "000000"
                    ? Text(widget.pengguna.username)
                    : Text(usersProvider.getUsers(widget.pengguna.nip).name),
                subtitle: widget.pengguna.nip == "000000"
                    ? Text(positionProvider
                        .getPosition(widget.pengguna.positionId)
                        .position)
                    : Text(usersProvider
                        .getUsers(widget.pengguna.nip)
                        .namaJabatan),
                trailing: widget.pengguna.jabatan == "atasan"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: isExpanded
                                ? Icon(Icons.keyboard_arrow_up)
                                : Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      )
                    : SizedBox())),
        if (isExpanded)
          Container(
              padding: EdgeInsets.only(left: 10),
              child: FutureBuilder<PenggunaResponse>(
                future: penggunaResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("No Data"),
                    );
                  } else if (snapshot.hasData) {
                    List<Pengguna> items = snapshot.data!.data;
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ItemListTim(
                            pengguna: items[index],
                          );
                        });
                  }

                  return CircularProgressIndicator();
                },
              ))
      ],
    );
  }
}
