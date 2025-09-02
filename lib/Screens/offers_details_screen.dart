import 'package:flutter/material.dart';

class OffersDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> offer;
  const OffersDetailsScreen({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = (offer['offer_name'] ?? '').toString();
    final desc = (offer['offer_description'] ?? '').toString();
    final img  = (offer['offer_image'] ?? '').toString();
    final exp  = (offer['expiredate'] ?? '').toString();

    String expiryText = '';
    if (exp.isNotEmpty) {
      try {
        final dt = DateTime.parse(exp).toLocal();
        expiryText =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) {}
    }

    final heroTag = 'offer-${offer['offer_id']}';

    return Scaffold(
      appBar: AppBar(title: Text(name, overflow: TextOverflow.ellipsis), backgroundColor: Colors.cyan),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: img.isEmpty
                  ? Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 48),
              )
                  : Image.network(
                img,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (expiryText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Expires on: $expiryText', style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 12),
          Text(
            desc.isEmpty ? 'No description available.' : desc,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}
