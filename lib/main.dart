import 'package:flutter/material.dart';
import 'Page/User/login_page.dart';
import 'Page/User/register_page.dart';
import 'Page/Book/book_list_page.dart';
import 'Page/Book/book_love_page.dart';
import 'Page/home_page.dart';
import 'Page/splash_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver], // 👈 thêm dòng này

      debugShowCheckedModeBanner: false,
      title: 'Read Book App',
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/books': (context) => const HomePage(),
      },
    
    );
  }
}
