import 'package:flutter/material.dart';
import 'package:testing/components/customstrings.dart';
import 'package:url_launcher/url_launcher.dart';

class GetHelpScreen extends StatelessWidget {
  const GetHelpScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppStrings.email,
      query: 'subject=Support Request&body=Hi Team,',
    );
    final ok = await launchUrl(emailLaunchUri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final isTablet = w >= 600;

    // font scaling helper (matches your other screens)
    double _fs(double base) {
      final scaled = base * (w / 390.0);
      return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Get Help",
          style: TextStyle(color: Colors.white, fontSize: _fs(18), fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.07).clamp(16, 28),
            vertical: (h * 0.04).clamp(16, 36),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: (w * 0.22).clamp(80, isTablet ? 140 : 120),
                    color: Colors.grey.shade800,
                  ),
                  SizedBox(height: (h * 0.025).clamp(12, 24)),
                  Text(
                    "Need Assistance?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _fs(22),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: (h * 0.012).clamp(8, 16)),
                  Text(
                    "Tap the button below to email our support team.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: _fs(14), color: Colors.black87),
                  ),
                  SizedBox(height: (h * 0.035).clamp(16, 28)),
                  SizedBox(
                    width: double.infinity,
                    height: (h * 0.065).clamp(44, 56),
                    child: ElevatedButton.icon(
                      onPressed: () => _launchEmail(context),
                      icon: const Icon(Icons.email, color: Colors.white),
                      label: Text("Contact Support", style: TextStyle(color: Colors.white, fontSize: _fs(16))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
