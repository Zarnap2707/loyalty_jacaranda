import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Services/session_manager.dart';
import '../Services/points_history_api.dart';
import 'Mycard_screen.dart';
import 'firstscreen.dart';
import 'shop_list_screen.dart';
import 'personal_info_screen.dart';
import 'package:uuid/uuid.dart';

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
  bool _showHistory = false;
  bool _isLoadingHistory = false;
  List<Map<String, dynamic>> _pointHistory = [];
  final String qrData = const Uuid().v4();
  final List<Map<String, String>> offerData = [
    {'image': 'assets/images/i1.jpeg', 'title': 'Exclusive Offer 1', 'description': 'Earn double points this weekend!'},
    {'image': 'assets/images/i2.jpeg', 'title': 'Exclusive Offer 2', 'description': 'Get 20% off your next purchase!'},
    {'image': 'assets/images/i3.jpeg', 'title': 'Exclusive Offer 3', 'description': 'Free shipping on orders above £50!'},
    {'image': 'assets/images/i4.jpeg', 'title': 'Exclusive Offer 4', 'description': 'Get 15% cashback on your purchase!'},
    {'image': 'assets/images/i5.jpeg', 'title': 'Exclusive Offer 5', 'description': 'Buy 1 get 1 free on select items!'},
    {'image': 'assets/images/i6.jpeg', 'title': 'Exclusive Offer 6', 'description': 'Free gift with every purchase over £100!'},
  ];

  void _onTabTapped(int index) {

    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCardScreen(
            userName: widget.name,
            userQRCodeData:qrData,
          ),  ),
      );
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ShopListScreen()));
    }
  }

  void _showAccountOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Personal Information"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalInfoScreen(name: widget.name, email: widget.email, mobile: widget.mobile),
                ),
              );
            },
          ),
          const ListTile(leading: Icon(Icons.privacy_tip), title: Text("Privacy & Sharing")),
          const ListTile(leading: Icon(Icons.help), title: Text("Get Help")),
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

  Future<void> _toggleHistory() async {
    if (_showHistory) {
      setState(() => _showHistory = false);
    } else {
      setState(() {
        _showHistory = true;
        _isLoadingHistory = true;
        _pointHistory = [];
      });

      try {
        final response = await PointsHistoryApi.fetchHistoryWithMessage();
        if (response['success']) {
          setState(() {
            _pointHistory = response['data'];
            _isLoadingHistory = false;
          });
        } else {
          setState(() => _isLoadingHistory = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to load history')),
          );
        }
      } catch (e) {
        setState(() => _isLoadingHistory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildPointsCard(BuildContext context, int points) {
    final cardHeight = MediaQuery.of(context).size.height * 0.12;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 4, color: Colors.teal.shade300),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 2.5, color: Colors.orange.shade300),
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.stars, size: 36, color: Color(0xFFFFD700)),
                          SizedBox(width: 14),
                          Text("Your Points", style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Text("${points} pts", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -22,
              left: MediaQuery.of(context).size.width / 2 - 20,
              child: GestureDetector(
                onTap: _toggleHistory,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.orange,
                  child: Icon(
                    _showHistory ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_isLoadingHistory) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    }
    if (_pointHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No Points History Available", style: TextStyle(fontSize: 16, color: Colors.black54)),
      );
    }

    return Column(
      children: _pointHistory.map((item) {
        final date = item['created_on'].split('T')[0];
        final shopname = item['shopname'] ?? '';
        final points = (item['is_redeem'] ?? 0) as int;
        final isNegative = points < 0;
        final color = isNegative ? Colors.red : Colors.green;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(shopname, style: const TextStyle(fontSize: 15)),
                ],
              ),
              Text(
                "${points > 0 ? '+' : ''}$points pts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _showAccountOptions(context)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildPointsCard(context, widget.points),
              if (_showHistory || _isLoadingHistory) _buildHistoryList(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Center(
                  child: Text('Your QR Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
                ),
              ),
              Center(
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 120.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Get More Offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: offerData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final offer = offerData[index];
                    return Container(
                      decoration: BoxDecoration(color: Color(0xFFF2F7FA), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.asset(offer['image']!, width: double.infinity, height: 110, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(offer['title']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                                const SizedBox(height: 6),
                                Text(offer['description']!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F7FA),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 14,
          unselectedFontSize: 13,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'My Card'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop List'),
          ],
        ),
      ),
    );
  }
}
