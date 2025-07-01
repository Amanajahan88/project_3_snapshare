import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            "Notification Page, Under Development.",
            style: TextStyle(color: Colors.red, fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
