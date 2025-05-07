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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() => _isUpdating = true);

    final token = await SessionManager.getToken();
    final success = await UpdateProfileApi.updateProfile(name, email, token ?? '');

    if (success) {
      final updatedProfile = await ProfileApi.getProfile(token ?? '');

      if (updatedProfile != null) {
        setState(() => _isUpdating = false);
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
        setState(() => _isUpdating = false);
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information",  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
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
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isUpdating ? null : _updateProfile,
                    child: _isUpdating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Update Profile", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Mobile No: ${widget.mobile}",
                  style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
