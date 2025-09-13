import 'package:flutter/material.dart';
import '../Page/Book/book_reader_page.dart';
import '../Services/api_service.dart';

class BookCard extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookCard({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool loved = false;

  @override
  void initState() {
    super.initState();
    checkIfLoved();
  }

  Future<void> checkIfLoved() async {
    try {
      final lovedBooks = await ApiService.fetchLovedBooks();
      final isInList = lovedBooks.any((book) => book['_id'] == widget.book['_id']);
      setState(() {
        loved = isInList;
      });
    } catch (e) {
      // Không xử lý lỗi để tránh crash
    }
  }

  Future<void> toggleLove() async {
    try {
      final message = await ApiService.toggleBookLove(widget.book['_id']);
      setState(() {
        loved = !loved;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thêm lấy thông tin lịch sử nếu có
    final lastPage = widget.book['lastPage'];
    final readAt = widget.book['readAt'] ?? widget.book['updatedAt'] ?? widget.book['createdAt'];

    String? formattedReadAt;
    if (readAt != null) {
      final dt = DateTime.tryParse(readAt.toString());
      if (dt != null) {
        formattedReadAt = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookReaderPage(
              pdfUrl: widget.book['pdfUrl'],
              title: widget.book['title'],
              bookId: widget.book['_id'],
            ),
          ),
        );
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // 📕 Ảnh bìa
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                widget.book['image'] ?? 'https://via.placeholder.com/150',
                width: 110,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),

            // 📄 Thông tin sách
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề + ❤️
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.book['title'] ?? 'Không có tiêu đề',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFB71C1C),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            loved ? Icons.favorite : Icons.favorite_border,
                            color: loved ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          onPressed: toggleLove,
                        ),
                      ],
                    ),

                    // Tác giả
                    Text(
                      'Tác giả: ${widget.book['author'] ?? 'Không rõ'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Mô tả ngắn
                    Expanded(
                      child: Scrollbar(child: SingleChildScrollView(
                        child: Text(
                          widget.book['description'] ?? 'Không có mô tả',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ),

                    // Thông tin lịch sử đọc (nếu có)
                    if (lastPage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Trang đã đọc: $lastPage',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB71C1C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (formattedReadAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Lần đọc gần nhất: $formattedReadAt',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
