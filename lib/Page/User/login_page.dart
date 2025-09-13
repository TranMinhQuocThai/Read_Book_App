import 'package:flutter/material.dart';
import '../../Services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String message = '';

  Future<void> handleLogin() async {
    try {
      final data = await ApiService.loginUser(username, password);

      // Lưu token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      setState(() => message = "Đăng nhập thành công!");


      // Chuyển sang BookListPage
 
      Navigator.pushReplacementNamed(context, '/books');
    } catch (e) {
      setState(() => message = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF9F6F6),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo-removebg.png', // Đặt tên ảnh giống như file bạn vừa gửi
              height: 180,
              width: 180,
            ),
            const SizedBox(height: 16),
           
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Tên người dùng',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => username = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Nhập username' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                 
                    ),
                    obscureText: true,
                    
                    onChanged: (val) => password = val,
                    validator: (val) => val == null || val.length < 6
                        ? 'Tối thiểu 6 ký tự'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handleLogin();
                        }
                      },
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text("Chưa có tài khoản? Đăng ký", style: TextStyle(color:  Color(0xFFB71C1C)),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
