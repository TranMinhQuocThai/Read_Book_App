import 'package:flutter/material.dart';
import '../../Services/api_service.dart';
import '../../widgets/book_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart'; // 👈 để dùng routeObserver

class BookLovePage extends StatefulWidget {
  const BookLovePage({Key? key}) : super(key: key);

  @override
  State<BookLovePage> createState() => _BookLovePageState();
}

class _BookLovePageState extends State<BookLovePage> with RouteAware {
  late Future<List<dynamic>> lovedBooksFuture;
  String username = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    lovedBooksFuture = ApiService.fetchLovedBooks();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    setState(() {
      username = storedUsername ?? 'bạn';
    });
  }

  // 👇 Khi quay lại trang này từ trang khác
  @override
  void didPopNext() {
    fetchData();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: FutureBuilder<List<dynamic>>(
        future: lovedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có sách yêu thích nào.'));
          }

          final lovedBooks = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: lovedBooks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemBuilder: (context, index) {
                final book = lovedBooks[index];
                return BookCard(
                  book: book,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
