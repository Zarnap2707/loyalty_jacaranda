import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // For QR Code generation

class MyCardScreen extends StatelessWidget {
  final String userName;
  final String userQRCodeData;

  const MyCardScreen({
    Key? key,
    required this.userName,
    required this.userQRCodeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final isTablet = screenWidth >= 600;

    // >>> CHANGED: font scaling helper
    double _fs(double base) {
      final scaled = base * (screenWidth / 390.0);
      return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
    }
    // <<<

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My QR Code",
          style: TextStyle(
            color: Colors.white,
            fontSize: _fs(18), // >>> CHANGED
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.cyan,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            height: screenHeight,
            padding: EdgeInsets.symmetric(
              horizontal: (screenWidth * 0.07).clamp(16, 32), // >>> CHANGED: responsive padding
              vertical: (screenHeight * 0.04).clamp(16, 40), // >>> CHANGED
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Your QR Code",
                    style: TextStyle(
                      fontSize: _fs(22), // >>> CHANGED
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: (screenHeight * 0.03).clamp(12, 28)), // >>> CHANGED
                  Text(
                    "Scan this QR code to earn the points",
                    style: TextStyle(
                      fontSize: _fs(14), // >>> CHANGED
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: (screenHeight * 0.04).clamp(16, 36)), // >>> CHANGED
                  QrImageView(
                    data: userQRCodeData,
                    version: QrVersions.auto,
                    size: (screenWidth * 0.55).clamp(160, 280), // >>> CHANGED: responsive QR size
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: mq.viewPadding.bottom + 20, // >>> CHANGED: safe area aware
            right: 20,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.cyan,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              mini: true,
            ),
          ),
        ],
      ),
    );
  }
}
