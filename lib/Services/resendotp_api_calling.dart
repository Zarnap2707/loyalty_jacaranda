import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class ResendOtpApi {
  static Future<bool> resendOtp(String mobile) async {
    final Map<String, dynamic> body = {'mobile': mobile};

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/resendOTP'),
        headers: {
          'Content-Type': 'application/json',
          'x-group-token': AppConfig.groupToken,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('OTP Resent Successfully: ${response.body}');
        return true;
      } else {
        print('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network Error: $e');
      return false;
    }
  }
}
