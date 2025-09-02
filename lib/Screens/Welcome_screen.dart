import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../Services/profile_api_calling.dart';
import '../Services/session_manager.dart';
import '../Services/points_history_api.dart';
import '../Services/offers_api.dart';

import 'Mycard_screen.dart';
import 'firstscreen.dart';
import 'offers_details_screen.dart';
import 'privacy_policy_screen.dart';
import 'shop_list_screen.dart';
import 'personal_info_screen.dart';
import 'GetHelpScreen.dart';

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

  // History
  bool _showHistory = false;
  bool _isLoadingHistory = false;
  bool _historyLoaded = false;
  List<Map<String, dynamic>> _pointHistory = [];

  // Offers
  List<Map<String, dynamic>> _offers = [];
  bool _offersLoading = true;
  String? _offersError;

  // QR
  String? _uuid;

  // Points shown on the card
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _points = widget.points; // seed from constructor
    _loadUuid();
    _loadOffers();
    _refreshPoints(); // fetch latest points on screen open
  }

  Future<void> _loadUuid() async {
    final u = await SessionManager.getuuid();
    if (!mounted) return;
    setState(() => _uuid = u);
  }

  Future<void> _loadOffers() async {
    try {
      final result = await OffersApi.fetchOffers();
      if (!mounted) return;
      if (result['success'] == true) {
        final data = (result['data'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _offers = data;
          _offersLoading = false;
          _offersError = null;
        });
      } else {
        setState(() {
          _offersLoading = false;
          _offersError = result['message']?.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _offersLoading = false;
        _offersError = 'Error loading offers: $e';
      });
    }
  }

  /// Refresh only the current points (no need to open history)
  Future<void> _refreshPoints() async {
    try {
      final bearer = await SessionManager.getToken();
      if (bearer == null || bearer.isEmpty) return;

      final r = await ProfileApi.getProfile(bearer);
      if (!mounted || r == null) return;

      // Try common shapes
      final candidates = [
        r['points'],
        r['data']?['points'],
        r['profile']?['points'],
        r['user']?['points'],
        r['owner']?['points'],
      ];

      int? parsed;
      for (final c in candidates) {
        final v = int.tryParse('${c ?? ''}');
        if (v != null) {
          parsed = v;
          break;
        }
      }

      if (parsed != null) {
        setState(() => _points = parsed!);
      }
    } catch (_) {
      // keep UI silent on errors; card will retain old value
    }
  }

  Future<void> _refreshHistory() async {
    try {
      final response = await PointsHistoryApi.fetchHistoryWithMessage();
      if (!mounted) return;
      if (response['success'] == true) {
        final list = (response['data'] as List).cast<Map<String, dynamic>>();

        // If backend returns current balance with history, sync the card too
        final p = response['current_points'] ??
            response['summary']?['current_points'] ??
            response['data_summary']?['current_points'] ??
            response['user']?['points'];
        final parsed = int.tryParse('${p ?? ''}');

        setState(() {
          _pointHistory = list;
          _isLoadingHistory = false;
          _historyLoaded = true;
          if (parsed != null) _points = parsed;
        });
      } else {
        setState(() => _isLoadingHistory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to load history')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingHistory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleHistory() async {
    if (_showHistory) {
      setState(() => _showHistory = false);
      return;
    }
    setState(() {
      _showHistory = true;
      if (!_historyLoaded) _isLoadingHistory = true;
      if (!_historyLoaded) _pointHistory = [];
    });
    if (_historyLoaded) return;
    await _refreshHistory();
  }

  double _fs(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 600;
    final scaled = base * (w / 390.0);
    return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyCardScreen(
            userName: widget.name,
            userQRCodeData: _uuid ?? '',
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ShopListScreen()));
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
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Personal Information"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalInfoScreen(
                    name: widget.name,
                    email: widget.email,
                    mobile: widget.mobile,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy & Sharing"),
            onTap: () {
              // If you have a dedicated privacy screen, navigate there
               Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Get Help"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GetHelpScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sign Out"),
            onTap: () async {
              await SessionManager.clearSession();
              await SessionManager.clearLastScreen();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => FirstScreen()),
                    (route) => false,
              );
            },
          ),
          const ListTile(title: Text("             ")),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int points) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;
    final double cardHeight = (size.height * 0.14).clamp(100.0, 140.0).toDouble();

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
                  border: Border.all(width: 4, color: Colors.cyan.shade300),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 2.5, color: Colors.orange.shade300),
                    color: Colors.transparent,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: (size.width * 0.05).clamp(16.0, 24.0),
                    vertical: (size.height * 0.02).clamp(12.0, 18.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            size: (size.width * 0.09).clamp(28.0, isTablet ? 42.0 : 36.0),
                            color: const Color(0xFFFFD700),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            "Your Points",
                            style: TextStyle(
                              fontSize: _fs(context, 14),
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "$points pts",
                        style: TextStyle(
                          fontSize: _fs(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -22,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleHistory,
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.white),
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
        child: Text(
          "No Points History Available",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Column(
      children: _pointHistory.map((item) {
        final date = (item['created_on'] ?? '').toString().split('T').first;
        final shopname = (item['shopname'] ?? '').toString();
        final points = int.tryParse('${item['points'] ?? 0}') ?? 0;
        final isNegative = points < 0;
        final color = isNegative ? Colors.red : Colors.green;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: TextStyle(fontSize: _fs(context, 14), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(shopname, style: TextStyle(fontSize: _fs(context, 15))),
                  ],
                ),
              ),
              Text(
                "${points > 0 ? '+' : ''}$points pts",
                style: TextStyle(fontSize: _fs(context, 16), fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final isTablet = w >= 600;
    final qrSize = (w * 0.35).clamp(110.0, isTablet ? 180.0 : 140.0);

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.cyan,
          elevation: 1,
          title: Row(
            children: [
              const Icon(Icons.person, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _fs(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadOffers();
              await _refreshPoints(); // refresh card points on pull-to-refresh
              if (_showHistory) {
                setState(() => _isLoadingHistory = true);
                await _refreshHistory();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: (w * 0.04).clamp(12, 20),
                vertical: (h * 0.01).clamp(8, 16),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildPointsCard(context, _points),
                  if (_showHistory || _isLoadingHistory) _buildHistoryList(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Center(
                      child: Text(
                        'Your QR Code',
                        style: TextStyle(
                          fontSize: _fs(context, 13),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: _uuid == null
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                        : Semantics(
                      label: 'Your QR Code',
                      child: QrImageView(
                        data: _uuid!,
                        version: QrVersions.auto,
                        size: qrSize,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Get More Offers',
                        style: TextStyle(
                          fontSize: _fs(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Builder(
                      builder: (_) {
                        if (_offersLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (_offersError != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Failed to load offers',
                                style: TextStyle(color: Colors.red, fontSize: _fs(context, 14)),
                              ),
                              const SizedBox(height: 8),
                              Text(_offersError!, style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _loadOffers, child: const Text('Retry')),
                            ],
                          );
                        }
                        if (_offers.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('No offers available right now.'),
                          );
                        }

                        final columns = w >= 900 ? 4 : (w >= 600 ? 3 : 2);

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _offers.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: w >= 600 ? 0.8 : 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final offer = _offers[index];
                            final name = (offer['offer_name'] ?? '').toString();
                            final img = (offer['offer_image'] ?? '').toString();
                            final heroTag = 'offer-${offer['offer_id']}';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OffersDetailsScreen(offer: offer),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: img.isEmpty
                                          ? Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image_not_supported),
                                      )
                                          : Hero(
                                        tag: heroTag,
                                        child: Image.network(
                                          img,
                                          width: double.infinity,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
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
            selectedItemColor: Colors.cyan,
            unselectedItemColor: Colors.grey,
            selectedFontSize: _fs(context, 14),
            unselectedFontSize: _fs(context, 13),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'My Card'),
              BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop List'),
            ],
          ),
        ),
      ),
    );
  }
}
