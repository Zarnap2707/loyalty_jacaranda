import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // For QR Code generation

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
        title: Text(
          "My DD Card",
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
        color: Colors.teal.shade50, // Full background color
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

              // QR Code display
              QrImageView(
                data: userQRCodeData, // Data passed to generate QR Code
                version: QrVersions.auto,
                size: screenWidth * 0.5, // Adjust size based on screen width
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 40),
              Text(
                "* Collect Points",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800, // Lighter teal text for description
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Scan QR description
              Text(
                "Scan your sign-up deal QR Code to:\n* Redeem your Visit deals\n* Add your missed points",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black, // Black for readability
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Scan QR Action Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Orange for action button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    // Add functionality for scanning QR or other actions
                  },
                  child: const Text(
                    "Tap Screen to Scan",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
