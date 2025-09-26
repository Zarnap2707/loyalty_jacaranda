import 'package:flutter/material.dart';
import '../Services/points_history_api.dart';

class FullPointsHistoryScreen extends StatefulWidget {
  const FullPointsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<FullPointsHistoryScreen> createState() => _FullPointsHistoryScreenState();
}

class _FullPointsHistoryScreenState extends State<FullPointsHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _history = [];

  double _fs(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 600;
    final scaled = base * (w / 390.0);
    return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await PointsHistoryApi.fetchHistoryWithMessage();
      if (!mounted) return;
      if (r['success'] == true) {
        final list = (r['data'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _history = list;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = r['message']?.toString() ?? 'Failed to load history';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error: $e';
      });
    }
  }

  Widget _buildRow(BuildContext context, Map<String, dynamic> item) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('All Points History', style: TextStyle(
          color: Colors.white,
           // >>> CHANGED
          fontWeight: FontWeight.w600,
        ),),
        backgroundColor: Colors.grey.shade800,
          iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ),
          ],
        )
            : _history.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 24),
            Center(child: Text('No Points History Available')),
          ],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _history.length,
          itemBuilder: (context, i) => _buildRow(context, _history[i]),
        ),
      ),
    );
  }
}
