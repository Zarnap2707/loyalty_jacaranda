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

  // >>> CHANGED: robust loader that matches your API shape and guards mounted
  Future<void> _loadHistory() async {
    try {
      final resp = await PointsHistoryApi.fetchHistoryWithMessage();
      if (!mounted) return;
      if (resp is Map && (resp['success'] == true) && resp['data'] is List) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(resp['data']);
          _isLoading = false;
        });
      } else if (resp is List) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(resp as Iterable);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp?['message'] ?? 'Failed to load history')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  // <<<

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);                     // >>> CHANGED
    final w = mq.size.width;                               // >>> CHANGED
    final h = mq.size.height;                              // >>> CHANGED
    final isTablet = w >= 600;                             // >>> CHANGED

    // >>> CHANGED: font scaling helper (same pattern as your other screens)
    double _fs(double base) {
      final scaled = base * (w / 390.0);
      return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
    }
    // <<<

    return Scaffold(
      appBar: AppBar(
        title: Text("Points History", style: TextStyle(fontSize: _fs(18), fontWeight: FontWeight.w600)), // >>> CHANGED
        backgroundColor: Colors.cyan,
      ),
      body: SafeArea( // >>> CHANGED
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_history.isEmpty)
            ? Center(
          child: Padding(
            padding: EdgeInsets.all((w * 0.06).clamp(16, 24)), // >>> CHANGED
            child: Text(
              "No history available",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: _fs(16), color: Colors.black54), // >>> CHANGED
            ),
          ),
        )
            : RefreshIndicator( // >>> CHANGED: pull-to-refresh
          onRefresh: _loadHistory,
          child: ListView.builder(
            padding: EdgeInsets.all((w * 0.04).clamp(12, 20)), // >>> CHANGED
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];

              // >>> CHANGED: null-safe reads
              final createdOn = (item['created_on'] ?? '').toString();
              final date = createdOn.split('T').first;
              final shopname = (item['shopname'] ?? '').toString();
              final isRedeem = (item['is_redeem'] == 1);
              final pointsRaw = item['points'];
              final int points = pointsRaw is int
                  ? pointsRaw
                  : int.tryParse(pointsRaw?.toString() ?? '0') ?? 0;
              final color = isRedeem ? Colors.red : Colors.green;
              final sign = isRedeem ? '-' : '+';
              // <<<

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.symmetric(
                  horizontal: (w * 0.03).clamp(12, 18),   // >>> CHANGED
                  vertical: (h * 0.015).clamp(10, 16),     // >>> CHANGED
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible( // >>> CHANGED: prevent overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date.isEmpty ? '—' : date,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fs(14)), // >>> CHANGED
                          ),
                          SizedBox(height: (h * 0.005).clamp(4, 8)), // >>> CHANGED
                          Text(
                            shopname.isEmpty ? '—' : shopname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // >>> CHANGED
                            style: TextStyle(fontSize: _fs(15)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$sign$points pts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _fs(16),        // >>> CHANGED
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
