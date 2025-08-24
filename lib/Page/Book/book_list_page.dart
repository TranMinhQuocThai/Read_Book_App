import 'package:flutter/material.dart';
import '../../Services/api_service.dart';
import '../../widgets/book_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart'; // 👈 để dùng được routeObserver

class BookListPage extends StatefulWidget {
  const BookListPage({Key? key}) : super(key: key);

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> with RouteAware {
  late Future<List<dynamic>> booksFuture;
  String username = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    booksFuture = ApiService.fetchBooks();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    setState(() {
      username = storedUsername ?? 'bạn';
    });
  }

  // 👇 Gọi lại khi quay về trang
  @override
  void didPopNext() {
    fetchData(); // gọi lại API khi quay về
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
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF9F6F6),
    
    body: FutureBuilder<List<dynamic>>(
      future: booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có sách nào.'));
        }

        final books = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: books.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              return BookCard(book: books[index]);
            },
          ),
        );
      },
    ),
  );
}

}
