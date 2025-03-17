import 'dart:convert';
import 'package:http/http.dart' as http;

class GetOtpApi {
  static const String _baseUrl = 'http://49.207.185.105:5000/api/auth/sendotp';
  static const String _Url = _baseUrl + 'auth/sendotp';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'x-group-token': 'U2FsdGVkX1+kjNXP5q6ISpgzlBO6WCISQ/a5vxzkQCQ=',
  };

  static Future<bool> sendOtp(String mobile) async {
    try {
      final Map<String, dynamic> body = {'mobile': mobile};

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('OTP Sent Successfully: ${response.body}');
        return true;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
}
