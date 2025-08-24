import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = 'http://192.168.1.5:5000';

  // đoạn code nếu api localhost chạy đc thì xài localhost còn ko thì uri bên trên
   static String baseUrl2 = 'https://bacend-read-book.onrender.com';


  // 🔑 Đăng nhập người dùng và lưu token
  static Future<void> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      // Lưu token và username (nếu cần dùng)
      await prefs.setString('token', data['token']);
      await prefs.setString('userId', data['user']['id']);
      await prefs.setString('username', data['user']['username']);
    } else {
      throw Exception(data['message'] ?? 'Đăng nhập thất bại');
    }
  }

  // 📚 Lấy danh sách sách (sau khi đã đăng nhập)
  static Future<List<dynamic>> fetchBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Chưa đăng nhập hoặc token đã hết hạn');
    }

    final response = await http.get(
      Uri.parse('$baseUrl2/api/books'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải danh sách sách');
    }
  }

  // 👤 Đăng ký người dùng mới
  static Future<String> registerUser(String username, String password, String password2) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username.trim(), 'password': password, 'password2': password2}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return 'Đăng ký thành công!';
    } else {
      throw Exception(data['message'] ?? 'Đăng ký thất bại');
    }
  }

  // ❤️ Thêm hoặc gỡ sách khỏi yêu thích
  static Future<String> toggleBookLove(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.put(
      Uri.parse('$baseUrl2/api/user/love/$bookId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data[
          'message']; // 'Đã thêm vào yêu thích' hoặc 'Đã gỡ khỏi yêu thích'
    } else {
      throw Exception(data['message'] ?? 'Lỗi khi xử lý yêu thích');
    }
  }

  // 💙 Lấy danh sách sách yêu thích
  static Future<List<dynamic>> fetchLovedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.get(
      Uri.parse('$baseUrl2/api/user/love'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['bookLove']; // danh sách sách yêu thích
    } else {
      throw Exception(data['message'] ?? 'Lỗi khi tải sách yêu thích');
    }
  }

  // ✍️ Thêm bình luận vào sách
  static Future<String> addComment(String bookId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.post(
      Uri.parse('$baseUrl2/api/books/$bookId/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data['message'] ?? 'Đã thêm bình luận';
    } else {
      throw Exception(data['message'] ?? 'Không thể thêm bình luận');
    }
  }

//  Xoá bình luận khỏi sách
  static Future<String> deleteComment(String bookId, String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl2/api/books/$bookId/comments/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? 'Đã xóa bình luận';
    } else {
      throw Exception(data['message'] ?? 'Không thể xóa bình luận');
    }
  }

  // 💬 Lấy danh sách bình luận của một cuốn sách
static Future<List<dynamic>> getComments(String bookId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.get(
    Uri.parse('$baseUrl2/api/books/$bookId/comments'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  debugPrint('getComments response: ${response.body}');

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    // ✅ Fix: dữ liệu trả về là List chứ không phải Map
    if (data is List) {
      return data;
    } else if (data is Map && data['comments'] is List) {
      return data['comments'];
    } else {
      return [];
    }
  } else {
    throw Exception(data['message'] ?? 'Không thể lấy bình luận');
  }
}
// 🧑‍🤝‍🧑 Lấy thông tin người dùng
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.get(
      Uri.parse('$baseUrl2/api/user/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    debugPrint('getUserInf: ${response.body}');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['user']; // trả về thông tin người dùng
    } else {
      throw Exception(data['message'] ?? 'Không thể lấy thông tin người dùng');
    }
  }
  // 🔄 Đổi mật khẩu
  static Future<String> changePassword(String oldPassword, String newPassword, String newPassword2) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }

    final response = await http.put(
      Uri.parse('$baseUrl2/api/user/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword.toString(),
        'newPassword': newPassword.toString(),
        'newPassword2': newPassword2.toString(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? 'Đổi mật khẩu thành công';
    } else {
      throw Exception(data['message'] ?? 'Không thể đổi mật khẩu');
    }
  }

  // search sách dữ liệu lấy từ body
  static Future<List<dynamic>> searchBooks(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl2/api/books/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).catchError((error) {
      throw Exception('Lỗi kết nối: $error');
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; // trả về danh sách sách tìm kiếm
    } else {
        throw Exception(data['message'] ?? 'Không thể tìm kiếm sách');
    }
  }

}
