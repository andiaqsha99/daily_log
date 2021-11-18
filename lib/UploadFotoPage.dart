import 'dart:io';

import 'package:daily_log/HomePage.dart';
import 'package:daily_log/MenuBottom.dart';
import 'package:daily_log/NotificationWidget.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadFotoPage extends StatefulWidget {
  final int idUser;
  const UploadFotoPage({Key? key, required this.idUser}) : super(key: key);

  @override
  _UploadFotoPageState createState() => _UploadFotoPageState();
}

class _UploadFotoPageState extends State<UploadFotoPage> {
  File? _image;
  final picker = ImagePicker();

  Future pickImage() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Foto"),
        actions: [NotificationWidget()],
      ),
      bottomNavigationBar: MenuBottom(),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          child: Column(children: [
            _image == null
                ? Text("Tidak ada foto")
                : CircleAvatar(
                    backgroundImage: FileImage(_image!),
                    maxRadius: 36,
                  ),
            ElevatedButton(
                onPressed: () {
                  pickImage();
                },
                child: Text("Pilih dari galeri")),
            ElevatedButton(
                onPressed: () async {
                  if (_image != null) {
                    var response = await ApiService()
                        .uploadFoto(widget.idUser.toString(), _image!.path);
                    print(widget.idUser);
                    print(response);
                    var sharedReference = await SharedPreferences.getInstance();
                    sharedReference.setString("foto", response);
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save"))
          ]),
        ),
      ),
    );
  }
}
