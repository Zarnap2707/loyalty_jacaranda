import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // >>> CHANGED: for input formatters
import 'package:testing/components/customstrings.dart';
import '../services/getotp_api_calling.dart';
import 'verify_otp_screen.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  // >>> CHANGED: small UX helpers
  final _formKey = GlobalKey<FormState>();
  void _dismissKeyboard() => FocusScope.of(context).unfocus();
  // <<<

  Future<void> _handleGetOtp() async {
    _dismissKeyboard(); // >>> CHANGED: dismiss keyboard before request

    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty || mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid mobile number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await GetOtpApi.snp(mobile);

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
        SnackBar(content: Text('${success['msg']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context); // >>> CHANGED: centralize MQ usage
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final isPortrait = mq.orientation == Orientation.portrait;

    // >>> CHANGED: responsive breakpoints + clamped font sizing
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth >= 400 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    double _fs(double base) {
      // base behaves like "dp"; scale slightly by width but clamp for readability
      final scaled = base * (screenWidth / 390.0);
      return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
    }
    // <<<

    return Scaffold(
      // >>> CHANGED: tap anywhere to dismiss keyboard
      body: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        // <<<
        child: Container(
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
              // >>> CHANGED: constrain max content width for big phones/tablets
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                // <<<
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    // >>> CHANGED: percentage padding with sensible minimums
                    horizontal: (screenWidth * 0.07).clamp(16, 28),
                    vertical: (screenHeight * 0.05).clamp(16, 40),
                    // <<<
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch, // >>> CHANGED
                    children: [
                      // >>> CHANGED: FittedBox to avoid overflow on tiny screens
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Icon(
                          Icons.star,
                          size: (screenWidth * 0.15).clamp(56, 92),
                          color: Colors.orange.shade700,
                        ),
                      ),
                      // <<<
                      SizedBox(height: (screenHeight * 0.03).clamp(12, 28)),
                      // >>> CHANGED: text scales with width and remains readable
                      Text(
                        AppStrings.welcomeMessage,
                        style: TextStyle(
                          fontSize: _fs(24),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // <<<
                      SizedBox(height: (screenHeight * 0.01).clamp(6, 14)),
                      Text(
                        AppStrings.getStarted,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _fs(16),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.04).clamp(16, 36)),
                      Container(
                        padding: EdgeInsets.all((screenWidth * 0.06).clamp(16, 28)),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.95),
                        ),
                        child: Form(
                          key: _formKey, // >>> CHANGED: use Form for validation
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch, // >>> CHANGED
                            children: [
                              // >>> CHANGED: FittedBox title
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Get Started",
                                  style: TextStyle(
                                    fontSize: _fs(20),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // <<<
                              SizedBox(height: (screenHeight * 0.02).clamp(10, 18)),
                              // >>> CHANGED: TextFormField with validation, formatters, a11y
                              TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleGetOtp(),
                                autofillHints: const [AutofillHints.telephoneNumber],
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10), // UK local 10 digits after +44
                                ],
                                style: TextStyle(fontSize: _fs(17)),
                                decoration: InputDecoration(
                                  hintText: "Enter Mobile No.",

                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                      left: (screenWidth * 0.03).clamp(8, 14),
                                      right: (screenWidth * 0.01).clamp(4, 8),
                                    ),
                                    child: Text(
                                      '+44 ',
                                      style: TextStyle(
                                        fontSize: _fs(17),
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: (screenHeight * 0.018).clamp(12, 18),
                                    horizontal: (screenWidth * 0.04).clamp(14, 20),
                                  ),
                                ),
                                validator: (v) {
                                  final t = (v ?? '').trim();
                                  if (t.isEmpty) return "Enter mobile number";
                                  if (t.length < 10) return "Enter valid 10-digit mobile";
                                  return null;
                                },
                              ),
                              // <<<
                              SizedBox(height: (screenHeight * 0.02).clamp(10, 18)),
                              SizedBox(
                                width: double.infinity,
                                height: (screenHeight * 0.065).clamp(44, isTablet ? 56 : 52), // >>> CHANGED
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      _handleGetOtp();
                                    }
                                  },
                                  // >>> CHANGED: AnimatedSwitcher for nicer loading UX
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: _isLoading
                                        ? const SizedBox(
                                      key: ValueKey('loading'),
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.8, color: Colors.white),
                                    )
                                        : Text(
                                      key: const ValueKey('label'),
                                      "Get OTP",
                                      style: TextStyle(fontSize: _fs(17), color: Colors.white),
                                    ),
                                  ),
                                  // <<<
                                ),
                              ),
                              SizedBox(height: (screenHeight * 0.02).clamp(10, 18)),
                              // >>> CHANGED: center + scalable caption
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "By continuing, you agree to our",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: _fs(12), color: Colors.grey[700]),
                                ),
                              ),
                              // <<<
                              TextButton(
                                onPressed: () {
                                  // >>> CHANGED: placeholder for route
                                  // TODO: Navigate to Terms/Privacy screen
                                },
                                child: Text(
                                  "Terms of Service and Privacy Policy",
                                  textAlign: TextAlign.center, // >>> CHANGED
                                  style: TextStyle(
                                    fontSize: _fs(13),
                                    color: Colors.cyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // >>> CHANGED: extra bottom space on devices with gesture nav
                      SizedBox(height: mq.viewPadding.bottom.clamp(8.0, 24.0)),
                      // <<<
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
