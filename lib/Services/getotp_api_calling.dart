import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class GetOtpApi {
  static Future<bool> sendOtp(String mobile) async {
    final Map<String, dynamic> body = {'mobile': mobile};

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/sendotp'),
      headers: {
        'Content-Type': 'application/json',
        'x-group-token': AppConfig.groupToken,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('OTP Sent Successfully: ${response.body}');
      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }
}
