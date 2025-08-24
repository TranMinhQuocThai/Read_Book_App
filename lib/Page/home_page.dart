import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Page/Book/book_list_page.dart';
import '../Page/Book/book_love_page.dart';
import '../Page/User/login_page.dart';
import '../Page/User/Person.dart';
import '../Page/Book/book_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  String username = 'bạn';

  final List<Widget> pages = [
    const BookListPage(),
    const BookLovePage(),
    const UserInfoScreen()
  ];

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'bạn';
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    const weekdayNames = [
      'Chủ nhật',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
    ];
    final weekday = weekdayNames[now.weekday % 7];
    return '$weekday, ngày ${now.day} tháng ${now.month}';
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFFB71C1C),
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/Logo_noText-removebg.png',
            height: 80,
            width: 80,
          ),
          const SizedBox(width: 3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, $username',
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                getFormattedDate(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () async {
          // Mở trang tìm kiếm sách
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookSearchPage()),
          );

        }, icon: const Icon(Icons.search, color: Colors.white)),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            final confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác nhận'),
                content: const Text('Bạn có chắc muốn đăng xuất?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Huỷ'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Đăng xuất'),
                  ),
                ]
              ),
            );
            if (confirm == true) {
              logout();
            }
          },
        ),
        
      ],
    ),
    body: pages[currentIndex],
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xFFB71C1C),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Sách',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Yêu thích',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ],
        ),
        
      ],
    ),
  );
}

}
