import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../Services/session_manager.dart';
import 'firstscreen.dart';
import 'map_screen.dart';
import 'shop_list_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final int points;

  const WelcomeScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.points,
  }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ShopListScreen()));
    } else if (index == 3) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
    }
  }

  void _showAccountOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.person), title: const Text("Personal Information")),
          ListTile(leading: const Icon(Icons.history), title: const Text("Points History")),
          ListTile(leading: const Icon(Icons.privacy_tip), title: const Text("Privacy & Sharing")),
          ListTile(leading: const Icon(Icons.help), title: const Text("Get Help")),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sign Out"),
            onTap: () async {
              await SessionManager.clearSession();
              await SessionManager.clearLastScreen();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => FirstScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final qrData = jsonEncode({
      "id": widget.id,
      "name": widget.name,
      "email": widget.email,
      "mobile": widget.mobile,
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showAccountOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Points Card
            Container(
              margin: EdgeInsets.all(screenWidth * 0.05),
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: screenWidth * 0.08),
                  SizedBox(width: screenWidth * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Points",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.points} pts = ₹${(widget.points * 0.1).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Offers Scroll Section
            SizedBox(
              height: screenHeight * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                itemBuilder: (context, index) => Container(
                  width: screenWidth * 0.42,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.teal.shade300, Colors.teal.shade100]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Exclusive Offer",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                      const Spacer(),
                      Text("Earn double points this weekend!",
                          style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.035))
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // QR Code
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: screenWidth * 0.45,
              backgroundColor: Colors.white,
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        selectedFontSize: screenWidth * 0.035,
        unselectedFontSize: screenWidth * 0.03,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'My Card'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop List'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
        ],
      ),
    );
  }
}
