import 'package:flutter/material.dart';
import '../Services/session_manager.dart';
import '../Services/update_profile_api.dart';
import '../Services/profile_api_calling.dart';
import 'Welcome_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String name;
  final String email;
  final String mobile;

  const PersonalInfoScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.mobile,
  }) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email;
  }

  @override
  void dispose() { // >>> CHANGED: lifecycle hygiene
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  } // <<<

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() => _isUpdating = true);

    final token = await SessionManager.getToken();
    final success = await UpdateProfileApi.updateProfile(name, email, token ?? '');

    if (!mounted) return; // >>> CHANGED: safe after await

    if (success) {
      final updatedProfile = await ProfileApi.getProfile(token ?? '');
      if (!mounted) return; // >>> CHANGED
      setState(() => _isUpdating = false);

      if (updatedProfile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomeScreen(
              id: updatedProfile['id'],
              name: updatedProfile['name'],
              mobile: updatedProfile['mobile'],
              email: updatedProfile['email'],
              points: updatedProfile['points'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch updated profile')),
        );
      }
    } else {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);                       // >>> CHANGED
    final w = mq.size.width;                                  // >>> CHANGED
    final h = mq.size.height;                                 // >>> CHANGED
    final isTablet = w >= 600;                                // >>> CHANGED

    // >>> CHANGED: font scaling helper (matches your other screens)
    double _fs(double base) {
      final scaled = base * (w / 390.0);
      return scaled.clamp(base * 0.9, base * (isTablet ? 1.4 : 1.15));
    }
    // <<<

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Personal Information",
          style: TextStyle(color: Colors.white, fontSize: _fs(18), fontWeight: FontWeight.w600), // >>> CHANGED
        ),
        backgroundColor: Colors.cyan,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea( // >>> CHANGED
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric( // >>> CHANGED: responsive paddings
            horizontal: (w * 0.07).clamp(16, 28),
            vertical: (h * 0.04).clamp(16, 36),
          ),
          child: Center( // >>> CHANGED: keeps tidy on tablets
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // NAME
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,              // >>> CHANGED
                      textCapitalization: TextCapitalization.words,       // >>> CHANGED
                      autofillHints: const [AutofillHints.name],          // >>> CHANGED
                      style: TextStyle(fontSize: _fs(16)),                // >>> CHANGED
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: _fs(14)),         // >>> CHANGED
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.person),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: (h * 0.018).clamp(12, 20),            // >>> CHANGED
                          horizontal: (w * 0.04).clamp(12, 20),           // >>> CHANGED
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: (h * 0.025).clamp(12, 24)),          // >>> CHANGED

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,              // >>> CHANGED
                      autofillHints: const [AutofillHints.email],         // >>> CHANGED
                      style: TextStyle(fontSize: _fs(16)),                // >>> CHANGED
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: _fs(14)),         // >>> CHANGED
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.email),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: (h * 0.018).clamp(12, 20),            // >>> CHANGED
                          horizontal: (w * 0.04).clamp(12, 20),           // >>> CHANGED
                        ),
                      ),
                      onFieldSubmitted: (_) => _updateProfile(),          // >>> CHANGED
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: (h * 0.035).clamp(14, 28)),          // >>> CHANGED

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: (h * 0.065).clamp(48, 56),                  // >>> CHANGED
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isUpdating ? null : _updateProfile,
                        child: _isUpdating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "Update Profile",
                          style: TextStyle(fontSize: _fs(16), color: Colors.white), // >>> CHANGED
                        ),
                      ),
                    ),

                    SizedBox(height: (h * 0.03).clamp(12, 24)),           // >>> CHANGED

                    // MOBILE
                    Text(
                      "Mobile No: ${widget.mobile}",
                      textAlign: TextAlign.center,                         // >>> CHANGED
                      style: TextStyle(fontSize: _fs(14), color: Colors.black87), // >>> CHANGED
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
