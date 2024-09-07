
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrcodeScreen extends StatefulWidget {
  const QrcodeScreen({super.key});

  @override
  State<QrcodeScreen> createState() => _QrcodeScreenState();
}

class _QrcodeScreenState extends State<QrcodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 4),
                color: Colors.white,
                child: QrImageView(
                  data: "Mohamed Elarousi",
                  version: 1,
                  size: 200.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
