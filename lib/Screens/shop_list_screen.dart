import 'package:flutter/material.dart';
import '../services/shop_list_api.dart';
import '../services/session_manager.dart';

class ShopListScreen extends StatefulWidget {
  @override
  _ShopListScreenState createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  List<Map<String, dynamic>> _shops = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    String? token = await SessionManager.getToken();
    if (token == null) return;

    final shops = await ShopListApi.fetchShops(token);
    setState(() {
      _shops = shops;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shop List"), backgroundColor: Colors.teal),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _shops.length,
        itemBuilder: (context, index) {
          final shop = _shops[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.store, color: Colors.teal),
              title: Text(shop['shopname'] ?? 'No Name'),
              subtitle: Text(shop['shopaddress'] ?? 'No Address'),
            ),
          );
        },
      ),
    );
  }
}
