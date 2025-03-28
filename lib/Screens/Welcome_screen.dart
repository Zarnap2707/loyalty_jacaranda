import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../Services/session_manager.dart';
import 'firstscreen.dart';
import 'map_screen.dart';
import 'shop_list_screen.dart'; // Make sure this is created and imported

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShopListScreen()),
      );
    }
    else if (index == 3) {
   //   Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
    }


    // You can handle other tabs later (QR Code, Maps, etc.)
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
    final qrData = jsonEncode({
      "id": widget.id,
      "name": widget.name,
      "email": widget.email,
      "mobile": widget.mobile,
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Text(widget.name, style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _showAccountOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Points Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your Points", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${widget.points} pts = ₹${(widget.points * 0.1).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),

          // Offers Scroll Section
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.teal.shade300, Colors.teal.shade100]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Exclusive Offer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text("Earn double points this weekend!", style: TextStyle(color: Colors.white70, fontSize: 12))
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // QR Code
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: Colors.white,
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
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
