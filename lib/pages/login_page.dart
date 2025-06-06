import 'package:flutter/material.dart';
import 'package:flutter_hello/widgets/banner.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            BannerWidget(title: 'Login Page'),

            BannerWidget(title: 'Login Page'),

          ],
        ),
      ),
    );
  }
}


