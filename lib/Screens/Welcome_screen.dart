import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // For QR Code generation

import '../Services/session_manager.dart';
import 'Mycard_screen.dart';
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

  // Mock API Data for Offers
  List<Map<String, String>> offerData = [
    {
      'image': 'assets/images/i1.jpeg',
      'title': 'Exclusive Offer 1',
      'description': 'Earn double points this weekend!',
    },
    {
      'image': 'assets/images/i2.jpeg',
      'title': 'Exclusive Offer 2',
      'description': 'Get 20% off your next purchase!',
    },
    {
      'image': 'assets/images/i3.jpeg',
      'title': 'Exclusive Offer 3',
      'description': 'Free shipping on orders above £50!',
    },
    {
      'image': 'assets/images/i4.jpeg',
      'title': 'Exclusive Offer 4',
      'description': 'Get 15% cashback on your purchase!',
    },
    {
      'image': 'assets/images/i5.jpeg',
      'title': 'Exclusive Offer 5',
      'description': 'Buy 1 get 1 free on select items!',
    },
    {
      'image': 'assets/images/i6.jpeg',
      'title': 'Exclusive Offer 6',
      'description': 'Free gift with every purchase over £100!',
    },
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCardScreen(
            userName: widget.name,
            userQRCodeData: jsonEncode({
              "id": widget.id,
              "name": widget.name,
              "email": widget.email,
              "mobile": widget.mobile,
            }),
          ),
        ),
      );
    }
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
                        style: TextStyle(fontSize: screenWidth * 0.09, color: Colors.teal),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Add SizedBox for Margin
          //  SizedBox(height: screenHeight * 0.02),  // Margin before GridView

            // GridView for offers
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cards per row
                  crossAxisSpacing: screenWidth * 0.05, // Horizontal space between cards
                  mainAxisSpacing: screenWidth * 0.05, // Vertical space between cards
                  childAspectRatio: 0.8, // Aspect ratio of the card (height/width)
                ),
                itemCount: offerData.length,
                itemBuilder: (context, index) {
                  final offer = offerData[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            offer['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: screenHeight * 0.12, // Image height
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                offer['description']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add SizedBox for Margin
            SizedBox(height: screenHeight * 0.03),  // Margin before BottomNavigationBar
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
        ],
      ),
    );
  }
}
