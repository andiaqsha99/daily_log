import 'dart:io';

import 'package:daily_log/api/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrCodePage extends StatelessWidget {
  const QrCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Scanner"),
      ),
      body: QRCodeScannerView(),
    );
  }
}

class QRCodeScannerView extends StatefulWidget {
  const QRCodeScannerView({Key? key}) : super(key: key);

  @override
  _QRCodeScannerViewState createState() => _QRCodeScannerViewState();
}

class _QRCodeScannerViewState extends State<QRCodeScannerView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String username = " ";
  Location location = new Location();

  @override
  void initState() {
    super.initState();
    getLoginData();
    getLocationData();
  }

  getLoginData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      username = sharedPreferences.getString("username")!;
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        buildQrView(context),
        Positioned(
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(8)),
            child: Text(
              result != null ? '${result!.code} success' : "Scan QR Code",
              style: TextStyle(color: Colors.white),
            ),
          ),
          top: 10,
        ),
        Positioned(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      icon: FutureBuilder<bool?>(
                          future: controller?.getFlashStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Icon(snapshot.data!
                                  ? Icons.flash_on
                                  : Icons.flash_off);
                            } else {
                              return Container();
                            }
                          })),
                  IconButton(
                      onPressed: () async {
                        await controller!.flipCamera();
                      },
                      icon: Icon(Icons.switch_camera)),
                ],
              )),
          bottom: 10,
        )
      ],
    );
  }

  Widget buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
          borderLength: 20,
          borderRadius: 10,
          borderWidth: 10,
          borderColor: Theme.of(context).colorScheme.secondary),
    );
  }

  onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
      readScan(controller);
    });
  }

  readScan(QRViewController controller) async {
    LocationData _locationData;
    _locationData = await location.getLocation();
    var latitude = _locationData.latitude;
    var longitude = _locationData.longitude;
    var a = await controller.scannedDataStream.first;
    setState(() {
      this.result = a;
    });

    switch (result!.code) {
      case 'Check In':
        await ApiService().checkInQRCode(username, latitude!, longitude!);
        showDialog(
            context: context,
            builder: (context) {
              return QrCodeSuccessPage(status: 'Check In');
            });
        break;
      case 'Check Out':
        await ApiService().checkOutQRCode(username);
        showDialog(
            context: context,
            builder: (context) {
              return QrCodeSuccessPage(status: 'Check Out');
            });
        break;
      default:
    }
  }

  getLocationData() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

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
  }
}

class QrCodeSuccessPage extends StatelessWidget {
  final String status;
  const QrCodeSuccessPage({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Scan Berhasil"),
      content: Text("$status berhasil"),
      actions: [
        TextButton(
            onPressed: () =>
                {Navigator.of(context).pop(), Navigator.of(context).pop()},
            child: Text("OK"))
      ],
    );
  }
}
