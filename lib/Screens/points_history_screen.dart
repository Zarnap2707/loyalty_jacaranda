import 'package:flutter/material.dart';
import '../Services/points_history_api.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await PointsHistoryApi.fetchHistoryWithMessage();
    setState(() {
      _history = data as List<Map<String, dynamic>>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Points History"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(child: Text("No history available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          final date = item['created_on'].split('T')[0];
          final shopname = item['shopname'] ?? '';
          final isRedeem = item['is_redeem'] == 1;
          final points = item['points'] ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(shopname),
                  ],
                ),
                Text(
                  "${isRedeem ? '-' : '+'}$points pts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isRedeem ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
