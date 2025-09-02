import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class VerifyOtpApi {
  static Future<Map<String, dynamic>?> verifyOtp(String mobile, String otp) async {
    final Map<String, dynamic> body = {
      'mobile': mobile,
      'otp': int.parse(otp),
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/verifyOTP'),
        headers: {
          'Content-Type': 'application/json',
          'x-group-token': AppConfig.groupToken,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
     //   print( 'uuu ${jsonDecode(response.body).uuid}');

        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

}
