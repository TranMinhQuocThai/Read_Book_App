import 'package:flutter/material.dart';
import '../../Services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String password2 = '';
  String message = '';

  Future<void> handleRegister() async {
    try {
      final result = await ApiService.registerUser(username, password, password2);
      setState(() => message = result);
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
              'assets/images/logo-removebg.png',
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
                      labelText: "Tên người dùng",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => username = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Nhập username' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Mật khẩu",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (val) => password = val,
                    validator: (val) =>
                        val == null || val.length < 6 ? 'Tối thiểu 6 ký tự' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Xác nhận mật khẩu",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (val) => password2 = val,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Nhập xác nhận mật khẩu';
                      }
                      if (val != password) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
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
                          handleRegister();
                        }
                      },
                      child: const Text(
                        "Đăng ký",
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
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text("Đã có tài khoản? Đăng nhập", style: TextStyle(color:  Color(0xFFB71C1C))),
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
