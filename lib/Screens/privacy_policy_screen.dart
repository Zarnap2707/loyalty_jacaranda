import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    TextStyle headingStyle = TextStyle(
      fontSize: screenWidth * 0.05,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade900,
    );

    TextStyle bodyStyle = TextStyle(
      fontSize: screenWidth * 0.04,
      color: Colors.black87,
      height: 1.5,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)), backgroundColor: Colors.grey.shade800, iconTheme: const IconThemeData(color: Colors.white)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Privacy and Sharing Policy", style: headingStyle),
                const SizedBox(height: 12),
               

                Text("1. Information We Collect", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "- Mobile Number (for OTP verification)\n"
                      "- Name and Email (for personalization)\n"
                      "- Device details (for security and diagnostics)",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("2. How We Use Your Information", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "- Authenticate and verify your identity\n"
                      "- Display your loyalty points and QR code\n"
                      "- Personalize offers and deals",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("3. Information Sharing", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "We do not sell your data. We may share information with:\n"
                      "- Partner stores (to validate rewards)\n"
                      "- Service providers (under strict confidentiality)",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("4. Data Storage and Security", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "- Data is secured using encrypted group tokens\n"
                      "- We use HTTPS and local storage for security",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("5. User Rights and Control", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "- View and update personal info\n"
                      "- Log out to clear session data\n"
                      "- Contact support to request deletion",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("6. Cookies and Tracking", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "We do not use cookies or external tracking tools.",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("7. Children’s Privacy", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "This app is not intended for children under 13 years old.",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("8. Changes to Policy", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "We may update this policy. Check this page for the latest version.",
                  style: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text("9. Contact Us", style: headingStyle),
                const SizedBox(height: 8),
                Text(
                  "Email to Jacaranda ",
                  style: bodyStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
