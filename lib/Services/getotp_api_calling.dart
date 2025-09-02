import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class GetOtpApi {
  static Future<bool> sendOtp(String mobile) async {
    final Map<String, dynamic> body = {'mobile': mobile};

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/sendotp'),
      headers: {
        'Content-Type': 'application/json',
        'x-group-token': AppConfig.groupToken,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {

      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }
  static Future<dynamic> snp(String mobile) async {
    final Map<String, dynamic> body = {'mobile': mobile};

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/sendotp'),
      headers: {
        'Content-Type': 'application/json',
        'x-group-token': AppConfig.groupToken,
      },
      body: jsonEncode(body),
    );
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('OTP Sent Successfully: ${response.body}');
      return {"result":true,"msg":jsonResponse['message']};
    } else {
      print('Error: ${response.body}');
      return {"result":false,"msg":jsonResponse['message']};
    }
  }
}
