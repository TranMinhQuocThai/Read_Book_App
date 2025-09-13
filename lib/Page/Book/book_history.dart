import 'package:flutter/material.dart';
import 'package:readbook_mobile/Services/api_service.dart';
import 'package:readbook_mobile/Widgets/Book_card.dart';

class BookHistoryPage extends StatefulWidget {
  const BookHistoryPage({Key? key}) : super(key: key);

  @override
  State<BookHistoryPage> createState() => _BookHistoryPageState();
}

class _BookHistoryPageState extends State<BookHistoryPage> {
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final history = await ApiService.getUserHistory();
      setState(() {
        _history = history;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải lịch sử đọc: $e')),
      );
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    final dt = DateTime.tryParse(date.toString());
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFFB71C1C);
    return Scaffold(
      
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB71C1C)))
          : _history.isEmpty
              ? Center(
                  child: Text(
                    'Không có lịch sử đọc',
                    style: TextStyle(fontSize: 18, color: mainColor, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final book = item['bookId'];
                    final lastPage = item['lastPage'] ?? item['page'] ?? 1;
                    final readAt = item['updatedAt'] ?? item['createdAt'];
                    final bookMap = book is Map ? Map<String, dynamic>.from(book) : <String, dynamic>{};

                    // Truyền thêm thông tin lịch sử vào bookMap để BookCard hiển thị
                    if (lastPage != null) bookMap['lastPage'] = lastPage;
                    if (readAt != null) bookMap['readAt'] = readAt;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {}, // Có thể mở lại sách nếu muốn
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 12),
                                Expanded(
                                  child: BookCard(book: bookMap),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

