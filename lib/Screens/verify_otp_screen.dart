import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../Services/session_manager.dart';
import '../Services/verifyotp_api_calling.dart';
import '../Services/resendotp_api_calling.dart';
import '../Services/profile_api_calling.dart';
import 'Welcome_screen.dart';
import 'update_profile_screen.dart';


class VerifyOtpScreen extends StatefulWidget {
  final String mobile;
  const VerifyOtpScreen({Key? key, required this.mobile}) : super(key: key);

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  Future<void> _handleVerify() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter complete OTP")));
      return;
    }

    setState(() => _isVerifying = true);

    final Map<String, dynamic>? response = await VerifyOtpApi.verifyOtp(widget.mobile, _otpController.text);

    if (response != null && response['token'] != null) {
      String token = response['token'];
      bool isRegistered = response['is_registered'] ?? false;
      await SessionManager.saveMobileAndToken(widget.mobile, token);

      if (isRegistered) {
        // ✅ Now call /profile API
        final profile = await ProfileApi.getProfile(token);

        setState(() => _isVerifying = false);

        if (profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                id: profile['id'],
                name: profile['name'],
                mobile: profile['mobile'],
                email: profile['email'] ?? '',
                points: profile['points'] ?? 0,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch profile")));
        }
      } else {
        setState(() => _isVerifying = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateProfileScreen(token: token),
          ),
        );
      }
    } else {
      setState(() => _isVerifying = false);
      _otpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid OTP")));
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);
    bool success = await ResendOtpApi.resendOtp(widget.mobile);
    setState(() => _isResending = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP resent successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to resend OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Verify OTP", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Code sent to ${widget.mobile}", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                autoFocus: true,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey.shade400,
                  activeColor: Colors.blue,
                ),
                onCompleted: (value) => _handleVerify(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _isResending ? null : _handleResendOtp,
                  child: Text(
                    _isResending ? "Resending OTP..." : "Didn't receive OTP? Resend OTP",
                    style: TextStyle(
                      color: _isResending ? Colors.grey : Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5D3EFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isVerifying ? null : _handleVerify,
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verify & Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
