import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class VerifyOtpApi {
  static Future<bool> verifyOtp(String mobile, String otp) async {
    final Map<String, dynamic> body = {
      'mobile': mobile,
      'otp': int.parse(otp),
    };

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/verifyOTP'),
      headers: {
        'Content-Type': 'application/json',
        'x-group-token': AppConfig.groupToken,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('OTP Verified Successfully: ${response.body}');
      return true;
    } else {
      print('OTP Verification Failed: ${response.body}');
      return false;
    }
  }
}
