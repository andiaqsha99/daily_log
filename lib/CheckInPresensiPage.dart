import 'package:daily_log/HomePage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/ProfilStatus.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/City.dart';
import 'package:daily_log/model/CityResponse.dart';
import 'package:daily_log/model/Presence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInPresensiPage extends StatefulWidget {
  final int idUser;
  const CheckInPresensiPage({Key? key, required this.idUser}) : super(key: key);

  @override
  _CheckInPresensiPageState createState() => _CheckInPresensiPageState();
}

class _CheckInPresensiPageState extends State<CheckInPresensiPage> {
  final formKey = GlobalKey<FormState>();
  late Future<CityResponse> cityResponse;

  List<City> listCity = [];
  TextEditingController _cityController = TextEditingController();
  TextEditingController _suhuController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  int valueRadio = 0;
  bool valueCheck = false;
  bool valueCheck1 = false;
  bool valueCheck2 = false;
  bool valueCheck3 = false;
  bool valueCheck4 = false;

  String condition = 'sehat';
  List<String> notes = [];
  City? city;

  getLocationData() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData.latitude);
    print(_locationData.longitude);
    print(_locationData.accuracy);
  }

  getLastCity() async {
    var sharedPreference = await SharedPreferences.getInstance();
    var lastCity = sharedPreference.getString("city");
    if (lastCity != null) {
      var latitude = sharedPreference.getString("latitude");
      var longitude = sharedPreference.getString("longitude");
      city = City(
          id: 1, city: lastCity, latitude: latitude!, longitude: longitude!);
      _cityController.text = lastCity;
    }
  }

  @override
  void initState() {
    cityResponse = ApiService().getCity();
    cityResponse.then((value) => listCity.addAll(value.data));
    super.initState();
    getLocationData();
    getLastCity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kehadiran"),
        actions: [NotificationWidget()],
      ),
      bottomNavigationBar: MenuBottom(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ProfilStatus(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kota/Kabupaten"),
                    TypeAheadFormField<City>(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: _cityController,
                          decoration: InputDecoration(
                              fillColor: Color(0xFFE3F5FF),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.city),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        return listCity.where((element) => element.city
                            .toLowerCase()
                            .contains(pattern.toLowerCase()));
                      },
                      onSuggestionSelected: (suggesion) {
                        setState(() {
                          _cityController.text = suggesion.city;
                          city = City(
                              id: suggesion.id,
                              city: suggesion.city,
                              latitude: suggesion.latitude,
                              longitude: suggesion.longitude);
                        });
                      },
                      validator: (value) {
                        return value != null && value.isEmpty
                            ? 'Masukkan kota'
                            : null;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(child: Text("Kondisi saat ini")),
                        Expanded(
                            child: Row(
                          children: [
                            Radio(
                                value: 0,
                                groupValue: valueRadio,
                                onChanged: (int? val) {
                                  setState(() {
                                    valueRadio = val!;
                                    condition = "sehat";
                                  });
                                }),
                            Text("Sehat"),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            Radio(
                                value: 1,
                                groupValue: valueRadio,
                                onChanged: (int? val) => {
                                      setState(() {
                                        valueRadio = val!;
                                        condition = "sakit";
                                      })
                                    }),
                            Text("Sakit"),
                          ],
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text("Suhu Tubuh"),
                    Container(
                      child: TextFormField(
                        controller: _suhuController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            fillColor: Color(0xFFE3F5FF),
                            filled: true,
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                        validator: (value) {
                          return value != null && value.isEmpty
                              ? 'Masukkan suhu tubuh'
                              : null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    valueRadio == 1 ? listCheckBox() : SizedBox(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        onPressed: () async {
                          final form = formKey.currentState;

                          if (form!.validate()) {
                            if (_noteController.text.isEmpty) {
                              notes.add(_noteController.text);
                            }
                            DateTime dateTime = DateTime.now();
                            var time = DateFormat("HH:mm:ss").format(dateTime);
                            var date =
                                DateFormat("yyyy-MM-dd").format(dateTime);
                            Presence presence = Presence(
                                id: 1,
                                idUser: widget.idUser,
                                temperature: _suhuController.text,
                                conditions: this.condition,
                                city: city!.city,
                                latitude: city!.latitude,
                                longitude: city!.longitude,
                                date: date,
                                checkInTime: time,
                                checkOutTime: null,
                                notes: null);

                            if (notes.isNotEmpty) {
                              presence.notes = notes.join(", ");
                            }
                            await ApiService().submitPresence(presence);
                            var sharedPreference =
                                await SharedPreferences.getInstance();
                            sharedPreference.setString("city", city!.city);
                            sharedPreference.setString(
                                "latitude", city!.latitude);
                            sharedPreference.setString(
                                "longitude", city!.longitude);
                            sharedPreference.setBool("is_checkin", true);
                            AlertDialog alertDialog = AlertDialog(
                              content: Text("Check In berhasil"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage()));
                                    },
                                    child: Text("OK"))
                              ],
                            );
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return alertDialog;
                                });
                          }
                        },
                        height: 48,
                        color: Theme.of(context).primaryColor,
                        // textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "CHECK IN",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget listCheckBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Keterangan"),
        Row(
          children: [
            Checkbox(
                value: valueCheck,
                onChanged: (value) {
                  setState(() {
                    this.valueCheck = value!;
                    if (value) {
                      insertNotes("Demam di atas 37 derajat");
                    } else {
                      if (notes.isNotEmpty) {
                        deleteNotes("Demam di atas 37 derajat");
                      }
                    }
                  });
                }),
            Text("Demam di atas 37 derajat")
          ],
        ),
        Row(
          children: [
            Checkbox(
                value: valueCheck1,
                onChanged: (value) {
                  setState(() {
                    this.valueCheck1 = value!;
                    if (value) {
                      insertNotes("Batuk");
                    } else {
                      if (notes.isNotEmpty) {
                        deleteNotes("Batuk");
                      }
                    }
                  });
                }),
            Text("Batuk")
          ],
        ),
        Row(
          children: [
            Checkbox(
                value: valueCheck2,
                onChanged: (value) {
                  setState(() {
                    this.valueCheck2 = value!;
                    if (value) {
                      insertNotes("Bersin-bersin");
                    } else {
                      if (notes.isNotEmpty) {
                        deleteNotes("Bersin-bersin");
                      }
                    }
                  });
                }),
            Text("Bersin-bersin")
          ],
        ),
        Row(
          children: [
            Checkbox(
                value: valueCheck3,
                onChanged: (value) {
                  setState(() {
                    this.valueCheck3 = value!;
                    if (value) {
                      insertNotes("Sakit tenggorokan");
                    } else {
                      if (notes.isNotEmpty) {
                        deleteNotes("Sakit tenggorokan");
                      }
                    }
                  });
                }),
            Text("Sakit tenggorokan")
          ],
        ),
        Row(
          children: [
            Checkbox(
                value: valueCheck4,
                onChanged: (value) {
                  setState(() {
                    this.valueCheck4 = value!;
                    if (value) {
                      insertNotes("Kesulitan bernafas");
                    } else {
                      if (notes.isNotEmpty) {
                        deleteNotes("Kesulitan bernafas");
                      }
                    }
                  });
                }),
            Text("Kesulitan bernafas")
          ],
        ),
        Text("Lainnya"),
        SizedBox(
          width: 32,
        ),
        TextFormField(
          controller: _noteController,
          decoration: InputDecoration(
              fillColor: Color(0xFFE3F5FF),
              filled: true,
              hintStyle: TextStyle(color: Colors.grey),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
        SizedBox(
          height: 8,
        )
      ],
    );
  }

  insertNotes(String value) {
    notes.add(value);
  }

  deleteNotes(String value) {
    notes.remove(value);
  }
}
