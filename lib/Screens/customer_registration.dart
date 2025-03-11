import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerRegistration extends StatefulWidget {
  @override
  _CustomerRegistrationState createState() => _CustomerRegistrationState();
}

class _CustomerRegistrationState extends State<CustomerRegistration> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false; // For showing loading indicator

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl = "http://158.220.94.87:5000/api/auth/register";
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "x-group-token": "U2FsdGVkX1+kjNXP5q6ISpgzlBO6WCISQ/a5vxzkQCQ=",
    };

    final Map<String, String> body = {
      "name": usernameController.text,
      "mobile": mobileController.text,
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      setState(() {
        isLoading = false;
      });
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Successful!")),
        );

        // Navigate back to the login screen
        Navigator.pop(context);
      } else {
        // Handle API error
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${errorData['message']} +  ${response.statusCode}")),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mobileController,
              decoration: InputDecoration(
                labelText: "Mobile",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator() // Show loading indicator
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: registerUser,
                child: const Text(
                  "Register",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}