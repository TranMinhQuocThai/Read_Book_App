import 'package:flutter/material.dart';
import 'package:readbook_mobile/Services/api_service.dart';
import 'package:readbook_mobile/Widgets/book_card.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({Key? key}) : super(key: key);

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchBooks() async {
    FocusScope.of(context).unfocus(); // ẩn bàn phím khi tìm kiếm

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final results = await ApiService.searchBooks(_searchController.text.trim());
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F6), // màu chủ đạo đồng bộ
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Tìm kiếm sách',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ô tìm kiếm
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _searchBooks(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Nhập tên sách...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.red,),
                    onPressed: _searchBooks,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kết quả
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? const Center(child: Text('Không tìm thấy sách nào.'))
                      : GridView.builder(
                          itemCount: _searchResults.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3.2,
                          ),
                          itemBuilder: (context, index) {
                            final book = _searchResults[index];
                            return BookCard(book: book);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
