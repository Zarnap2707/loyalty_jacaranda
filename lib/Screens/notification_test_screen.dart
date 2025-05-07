import 'package:flutter/material.dart';

import '../Services/notification_service.dart';


class NotificationTestScreen extends StatefulWidget {
  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Push Test')),
      body: Center(child: Text('Waiting for push notification...')),
    );
  }
}
