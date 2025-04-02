import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Method to open the Google Maps app with the shop address
  void _openMap(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);

    // Try to launch Google Maps app directly
  /*  final String url = 'google.maps://?q=$encodedAddress';

    // Check if the device has the Google Maps app installed
    if (await canLaunch(url)) {
      await launch(url); // Launch the Google Maps app
    } else {
      // If Google Maps is not installed, fallback to opening the address in a browser
      final String fallbackUrl = 'https://www.google.com/maps/search/?q=$encodedAddress';
      if (await canLaunch(fallbackUrl)) {
        await launch(fallbackUrl); // Open the address in browser if app is not available
      } else {
        throw 'Could not open Google Maps';
      }
    } */
    final Uri googleMapsUri = Uri.parse('google.maps://?q=$encodedAddress');
    final Uri mapSearchUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    final Uri appleMapsUri = Uri.parse('http://maps.apple.com/?daddr=$encodedAddress');
    final Uri fallbackWebUri = Uri.parse('https://www.google.com/maps/search/?q=$encodedAddress');

    try {
      if (Platform.isIOS) {
        // Try Google Maps app first
        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        }
        // Fallback to Apple Maps
        else if (await canLaunchUrl(appleMapsUri)) {
          await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
        }
        // Fallback to web
        else {
          await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
        }
      } else {
        // Android logic (already working)
        final Uri androidIntent = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
        if (await canLaunchUrl(androidIntent)) {
          await launchUrl(androidIntent, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('Map error: $e');
    }
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
              onTap: () {
                // Open Google Maps app when a shop is tapped
                _openMap(shop['shopaddress'] ?? '');
                print("list item tapped");
              },
            ),
          );
        },
      ),
    );
  }
}
