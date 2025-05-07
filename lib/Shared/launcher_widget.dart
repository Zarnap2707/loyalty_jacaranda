import 'package:flutter/material.dart';
import '../Screens/Welcome_screen.dart';
import '../Screens/firstscreen.dart';
import '../Screens/update_profile_screen.dart';
import '../Services/session_manager.dart';
import '../Services/profile_api_calling.dart';
import '../Services/notification_service.dart';

class LauncherWidget extends StatefulWidget {
  const LauncherWidget({Key? key}) : super(key: key);

  @override
  State<LauncherWidget> createState() => _LauncherWidgetState();
}

class _LauncherWidgetState extends State<LauncherWidget> {
  bool _loading = true;
  Widget _startScreen = FirstScreen();

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
    _decideStartScreen();
  }

  Future<void> _decideStartScreen() async {
    final token = await SessionManager.getToken();
    final lastScreen = await SessionManager.getLastScreen();

    if (token != null) {
      final profile = await ProfileApi.getProfile(token);

      // If profile has name and email -> WelcomeScreen, else -> UpdateProfile
      if (profile != null && profile['name'] != null && profile['email'] != null && profile['name'].toString().isNotEmpty && profile['email'].toString().isNotEmpty) {
        await SessionManager.setLastScreen("WelcomeScreen");
        _startScreen = WelcomeScreen(
          id: profile['id'],
          name: profile['name'],
          mobile: profile['mobile'],
          email: profile['email'],
          points: profile['points'] ?? 0,
        );
      } else {
        _startScreen = UpdateProfileScreen(token: token);
      }
    } else {
      _startScreen = FirstScreen();
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? const Scaffold(body: Center(child: CircularProgressIndicator())) : _startScreen;
  }
}
