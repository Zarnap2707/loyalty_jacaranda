import 'package:flutter/material.dart';
import '../services/getotp_api_calling.dart';
import 'verify_otp_screen.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleGetOtp() async {
    String mobile = _mobileController.text.trim();
    if (mobile.isEmpty || mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid mobile number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    dynamic success = await GetOtpApi.snp(mobile);

    setState(() => _isLoading = false);

    if (success['result']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOtpScreen(mobile: mobile),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${success['msg']}')), // ✅ Fixed line
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.teal.shade300, Colors.teal.shade100],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.07,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: screenWidth * 0.15, color: Colors.orange),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    "Earn 500 Bonus Points",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color:   Colors.teal.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Get £0.50 in your balance just by getting in today",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.95),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: screenWidth * 0.045),
                          decoration: InputDecoration(
                            hintText: "Enter Mobile No.",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.018,
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.065,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleGetOtp,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              "Get OTP",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "By continuing, you agree to our",
                          style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Terms of Service and Privacy Policy",
                            style: TextStyle(
                              fontSize: screenWidth * 0.033,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
