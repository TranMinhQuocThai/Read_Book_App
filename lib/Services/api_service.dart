import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl2 = 'http://192.168.1.10:5000';
  static String baseUrl = 'https://bacend-read-book.onrender.com';

  // ========================= 🔑 AUTH =========================
  // Đăng nhập
  static Future<void> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username.trim(), 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userId', data['user']['id']);
      await prefs.setString('username', data['user']['username']);
    } else {
      throw Exception(data['message'] ?? 'Đăng nhập thất bại');
    }
  }

  // Đăng ký
  static Future<String> registerUser(
    String username,
    String password,
    String password2,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password,
        'password2': password2,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return 'Đăng ký thành công!';
    } else {
      throw Exception(data['message'] ?? 'Đăng ký thất bại');
    }
  }

  // ========================= 👤 USER =========================
  // Lấy thông tin cá nhân
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl2/api/user/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    debugPrint('getUserInfo: ${response.body}');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['user'];
    } else {
      throw Exception(data['message'] ?? 'Không thể lấy thông tin người dùng');
    }
  }

  // Đổi mật khẩu
  static Future<String> changePassword(
    String oldPassword,
    String newPassword,
    String newPassword2,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl2/api/user/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'newPassword2': newPassword2,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Đổi mật khẩu thành công';
    } else {
      throw Exception(data['message'] ?? 'Không thể đổi mật khẩu');
    }
  }

  // ========================= 📚 BOOK =========================
  // Lấy danh sách sách
  static Future<List<dynamic>> fetchBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var response = await http.get(
      Uri.parse('$baseUrl2/api/books'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final books = jsonDecode(response.body);
      // Lọc bỏ sách ẩn (hidden == true)
      if (books is List) {
        return books.where((b) => !(b is Map && (b['hidden'] == true))).toList();
      }
      return [];
    } else {
      throw Exception('Không thể tải danh sách sách');
    }
  }

  // Tìm kiếm sách
  static Future<List<dynamic>> searchBooks(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl2/api/books/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Không thể tìm kiếm sách');
    }
  }

  // ========================= ❤️ LOVE =========================
  // Thêm / gỡ khỏi yêu thích
  static Future<String> toggleBookLove(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl2/api/user/love/$bookId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception(data['message'] ?? 'Lỗi khi xử lý yêu thích');
    }
  }

  // Lấy sách yêu thích
  static Future<List<dynamic>> fetchLovedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl2/api/user/love'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    debugPrint('fetchLovedBooks response: ${response.body}');
    if (response.statusCode == 200) {
      // hãy kiểm tra hidden
      if (data['bookLove'] is List) {
        return (data['bookLove'] as List)
            .where((b) => !(b is Map && (b['hidden'] == true)))
            .toList();
      }
      return data['bookLove'];
    } else {
      throw Exception(data['message'] ?? 'Lỗi khi tải sách yêu thích');
    }
  }

  // ========================= 💬 COMMENT =========================
  // Thêm bình luận
  static Future<String> addComment(String bookId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

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

  // Xóa bình luận
  static Future<String> deleteComment(String bookId, String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

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

  // Lấy bình luận
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

  // ========================= 📖 HISTORY =========================
  // Lưu hoặc cập nhật trang đã đọc
  static Future<void> saveReadingProgress(String bookId, int lastPage) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('$baseUrl2/api/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'bookId': bookId,
        'lastPage': lastPage,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
            debugPrint('không cập đc lịch sử đọc');

      throw Exception(data['message'] + 'Không thể lưu lịch sử đọc');
    }
  }

  // Lấy lịch sử đọc theo user
  static Future<List<dynamic>> getUserHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    final response = await http.get(
      Uri.parse('$baseUrl2/api/history/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Không thể lấy lịch sử đọc');
    }
  }
  // ========================= 📖 GENRES =========================
  // Lấy danh sách thể loại
  static Future<List<dynamic>> fetchGenres() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl2/api/genres'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data is List) {
        return data;
      } else if (data is Map && data['genres'] is List) {
        return data['genres'];
      } else {
        return [];
      }
    } else {
      throw Exception(data['message'] ?? 'Không thể lấy danh sách thể loại');
    }
  }
// lấy theo id
  static Future<Map<String, dynamic>> fetchGenreById(String genreId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl2/api/genres/$genreId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data is Map && data['genre'] is Map<String, dynamic>) {
        return data['genre'];
      } else {
        throw Exception('Dữ liệu thể loại không hợp lệ');
      }
    } else {
      throw Exception(data['message'] ?? 'Không thể lấy thông tin thể loại');
    }
  }
  
}
