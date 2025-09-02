import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  // lifecycle hygiene
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  Future<void> _handleVerify() async {
    _dismissKeyboard();

    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter complete OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    final Map<String, dynamic>? response =
    await VerifyOtpApi.verifyOtp(widget.mobile, _otpController.text);

    if (!mounted) return; // safe after await

    if (response != null && response['token'] != null) {
      final String token = response['token'];
      final String uuid = (response['uuid'] ?? '') as String;
      final bool isRegistered = response['is_registered'] ?? false;

      await SessionManager.saveMobileAndTokenAndUuid(widget.mobile, token, uuid);

      if (!mounted) return;

      if (isRegistered) {
        final profile = await ProfileApi.getProfile(token);
        if (!mounted) return;
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch profile")),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);
    final success = await ResendOtpApi.resendOtp(widget.mobile);
    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "OTP resent successfully" : "Failed to resend OTP"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final keyboard = mq.viewInsets.bottom;
    final bottomSafe = mq.viewPadding.bottom;

    // breakpoints + font scaler (matches your FirstScreen pattern)
    final isTablet = screenWidth >= 600;
    double _fs(double base) {
      final scaled = base * (screenWidth / 390.0);
      return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
    }

    // Pin field sizing with sensible clamps
    final fieldHeight = (screenHeight * 0.07).clamp(48.0, isTablet ? 64.0 : 56.0);
    final fieldWidth = (screenWidth * 0.13).clamp(44.0, isTablet ? 60.0 : 52.0);

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Colors.cyan, Colors.cyan.shade200],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    (screenWidth * 0.07).clamp(16, 28),
                    (screenHeight * 0.05).clamp(16, 40),
                    (screenWidth * 0.07).clamp(16, 28),
                    (screenHeight * 0.02).clamp(12, 24) + keyboard + bottomSafe,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: _fs(24),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.01).clamp(6, 14)),
                      Text(
                        "Code sent to ${widget.mobile}",
                        style: TextStyle(
                          fontSize: _fs(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      SizedBox(height: (screenHeight * 0.04).clamp(16, 36)),

                      // OTP boxes
                      Semantics(
                        label: 'Enter the 6-digit one-time password',
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: _otpController,
                          autoFocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: fieldHeight,
                            fieldWidth: fieldWidth,
                            activeFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            selectedFillColor: Colors.white,
                            inactiveColor: Colors.white,
                            activeColor: Colors.cyan,
                            selectedColor: Colors.cyan.shade700,
                          ),
                          onCompleted: (_) => _handleVerify(),
                          onChanged: (_) {},
                        ),
                      ),

                      SizedBox(height: (screenHeight * 0.02).clamp(10, 18)),

                      // Resend link
                      Center(
                        child: GestureDetector(
                          onTap: _isResending ? null : _handleResendOtp,
                          child: Text(
                            _isResending ? "Resending OTP..." : "Didn't receive OTP? Resend OTP",
                            style: TextStyle(
                              color: _isResending ? Colors.grey : Colors.grey.shade700,
                              fontSize: _fs(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: (screenHeight * 0.06).clamp(20, 40)),

                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        height: (screenHeight * 0.065).clamp(48, isTablet ? 56 : 52),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _isVerifying ? null : _handleVerify,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isVerifying
                                ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.8, color: Colors.white),
                            )
                                : Text(
                              key: const ValueKey('label'),
                              "Verify & Login",
                              style: TextStyle(
                                fontSize: _fs(17),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
