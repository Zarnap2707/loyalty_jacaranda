import 'package:flutter/material.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
// For QR Code generation
// Import the QRCodeScannerScreen

class MyCardScreen extends StatelessWidget {
  final String userName;
  final String userQRCodeData; // You can pass the QR code data here.

  const MyCardScreen({
    Key? key,
    required this.userName,
    required this.userQRCodeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // 👈 White back arrow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "My QR Code",
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
            color: Colors.white, // AppBar text color same as in WelcomeScreen
          ),
        ),
        backgroundColor: Colors.teal, // Teal color for AppBar
        elevation: 0,
      ),
      body: Container(
        color: Colors.white, // Full background color
        width: double.infinity,
        height: screenHeight, // Full screen height
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header text
              Text(
                "Your QR Code",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900, // Dark teal text for contrast
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Scan this QR code to earn the points",

                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700, // Dark teal text for contrast
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // QR Code display
              QrImageView(
                data: userQRCodeData, // Data passed to generate QR Code
                version: QrVersions.auto,
                size: screenWidth * 0.5, // Adjust size based on screen width
                backgroundColor: Colors.white,
              ),


            ],
          ),
        ),
      ),
    );
  }
}
