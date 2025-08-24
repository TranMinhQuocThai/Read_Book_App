import 'package:flutter/material.dart';
import 'dart:async';
import './User/login_page.dart'; // Đường dẫn đến LoginPage

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ⏱️ Đợi 2 giây rồi chuyển sang LoginPage
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1), // 🎨 nền giống logo
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 tách trên - giữa - dưới
          children: [
            const SizedBox(), // khoảng trống phía trên
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child:   Image.asset(
                  'assets/images/logo-removebg.png',
                  height: 180,
                  width: 180,
                ),
                )
              
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Text(
                '© 2025 Read Book App ', // 👈 dòng chữ dưới cùng
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Developer: Trần Minh Quốc Thái ', // 👈 dòng chữ dưới cùng
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
                ],
              )
            ),
            
          ],
        ),
      ),
    );
  }
}
