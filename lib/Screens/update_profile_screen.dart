import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // >>> CHANGED: for minor formatters
import '../Services/profile_api_calling.dart';
import '../Services/session_manager.dart';
import '../Services/update_profile_api.dart';
import 'Welcome_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String token;
  const UpdateProfileScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isUpdating = false;

  // >>> CHANGED: optional prefill of existing profile (no API change)
  @override
  void initState() {
    super.initState();
    _prefillProfile();
  }

  Future<void> _prefillProfile() async {
    final profile = await ProfileApi.getProfile(widget.token);
    if (!mounted || profile == null) return;
    // only prefill if empty (to not overwrite user typing on hot reload)
  //  if ((_nameController.text).isEmpty) _nameController.text = (profile['name'] ?? '').toString();
    if ((_emailController.text).isEmpty) _emailController.text = (profile['email'] ?? '').toString();
    setState(() {}); // reflect any initial values
  }
  // <<<

  // >>> CHANGED: lifecycle hygiene
  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  // <<<

  // >>> CHANGED: small UX helper
  void _dismissKeyboard() => FocusScope.of(context).unfocus();
  // <<<

  Future<void> _handleUpdateProfile() async {
    _dismissKeyboard(); // >>> CHANGED
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    setState(() => _isUpdating = true);

    final success = await UpdateProfileApi.updateProfile(name, email, widget.token);

    if (!mounted) return; // >>> CHANGED: safe after await

    if (success) {
      await SessionManager.setLastScreen("WelcomeScreen"); // unchanged
      final profile = await ProfileApi.getProfile(widget.token);

      if (!mounted) return; // >>> CHANGED
      setState(() => _isUpdating = false);

      if (profile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomeScreen(
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
          const SnackBar(content: Text("Failed to fetch profile data")),
        );
      }
    } else {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context); // >>> CHANGED: centralize MQ usage
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final keyboard = mq.viewInsets.bottom;           // >>> CHANGED: keyboard-aware
    final bottomSafe = mq.viewPadding.bottom;        // >>> CHANGED: safe-area padding
    final isTablet = screenWidth >= 600;             // >>> CHANGED: breakpoint

    // >>> CHANGED: font scaler with clamp (matches your style)
    double _fs(double base) {
      final scaled = base * (screenWidth / 390.0);
      return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
    }
    // <<<

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector( // >>> CHANGED: tap anywhere to dismiss keyboard
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey, Colors.grey.shade200],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(                // >>> CHANGED: keep content readable on large screens
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(     // >>> CHANGED: keyboard + safe-area aware padding
                      (screenWidth * 0.07).clamp(16, 28),
                      (screenHeight * 0.04).clamp(16, 36),
                      (screenWidth * 0.07).clamp(16, 28),
                      (screenHeight * 0.02).clamp(12, 24) + keyboard + bottomSafe,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FittedBox(                  // >>> CHANGED: avoid overflow on tiny screens
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Complete your profile",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _fs(22),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ),
                          SizedBox(height: (screenHeight * 0.04).clamp(16, 36)),

                          // NAME
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,       // >>> CHANGED
                            textCapitalization: TextCapitalization.words, // >>> CHANGED
                            autofillHints: const [AutofillHints.name],    // >>> CHANGED
                            inputFormatters: [                           // >>> CHANGED: light constraints
                              LengthLimitingTextInputFormatter(60),
                            ],
                            style: TextStyle(fontSize: _fs(16)),
                            decoration: InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: (screenHeight * 0.018).clamp(12, 18),
                                horizontal: (screenWidth * 0.04).clamp(14, 20),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: (screenHeight * 0.025).clamp(10, 20)),

                          // EMAIL
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,         // >>> CHANGED
                            autofillHints: const [AutofillHints.email],    // >>> CHANGED
                            inputFormatters: [                             // >>> CHANGED: trim spaces
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              LengthLimitingTextInputFormatter(100),
                            ],
                            style: TextStyle(fontSize: _fs(16)),
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: (screenHeight * 0.018).clamp(12, 18),
                                horizontal: (screenWidth * 0.04).clamp(14, 20),
                              ),
                            ),
                            onFieldSubmitted: (_) => _handleUpdateProfile(), // >>> CHANGED
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: (screenHeight * 0.04).clamp(16, 36)),

                          // BUTTON
                          SizedBox(
                            height: (screenHeight * 0.065).clamp(48, isTablet ? 56 : 52), // >>> CHANGED: hit target
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isUpdating ? null : _handleUpdateProfile,
                              child: AnimatedSwitcher(                 // >>> CHANGED: smoother loading
                                duration: const Duration(milliseconds: 250),
                                child: _isUpdating
                                    ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.8, color: Colors.white),
                                )
                                    : Text(
                                  key: const ValueKey('label'),
                                  "Update Profile",
                                  style: TextStyle(
                                    fontSize: _fs(16.5),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,   // >>> CHANGED: better contrast
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
        ),
      ),
    );
  }
}
