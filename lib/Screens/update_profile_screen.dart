import 'package:flutter/material.dart';
import '../Services/profile_api_calling.dart';
import '../Services/update_profile_api.dart';
import '../services/session_manager.dart';
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
  bool _isUpdating = false;

  Future<void> _handleUpdateProfile() async {
    String email = _emailController.text.trim();
    String name = _nameController.text.trim();

    if (email.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter all fields")));
      return;
    }

    setState(() => _isUpdating = true);

    final success = await UpdateProfileApi.updateProfile(name, email, widget.token);

    if (success) {
      final profile = await ProfileApi.getProfile(widget.token);
      setState(() => _isUpdating = false);

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
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isUpdating ? null : _handleUpdateProfile,
                child: _isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Profile", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
