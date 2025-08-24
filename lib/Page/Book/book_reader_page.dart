import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../Services/api_service.dart';
import '../../Widgets/comment_list.dart';
import "package:shared_preferences/shared_preferences.dart";

class BookReaderPage extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final String bookId;

  const BookReaderPage({
    Key? key,
    required this.pdfUrl,
    required this.title,
    required this.bookId,
  }) : super(key: key);

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  bool loved = false;

  @override
  void initState() {
    super.initState();
    checkIfLoved();
  }

  Future<void> checkIfLoved() async {
    try {
      final lovedBooks = await ApiService.fetchLovedBooks();
      final isInList = lovedBooks.any((book) => book['_id'] == widget.bookId);
      setState(() {
        loved = isInList;
      });
    } catch (e) {
      // không hiển thị lỗi nếu offline
    }
  }

  Future<void> toggleLove() async {
    try {
      final message = await ApiService.toggleBookLove(widget.bookId);
      setState(() {
        loved = !loved;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CommentBottomSheet(bookId: widget.bookId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            pageLayoutMode: PdfPageLayoutMode.single,
            scrollDirection: PdfScrollDirection.horizontal,
          ),
          // Nút Back
          Positioned(
            top: 30,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black87,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),

          // Nút Love
          Positioned(
            top: 30,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: toggleLove,
              child: Icon(
                loved ? Icons.favorite : Icons.favorite_border,
                color: loved ? Colors.red : Colors.grey,
              ),
            ),
          ),

          // Logo giữa đỉnh
          Positioned(
            top: 24,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/Logo_noText-removebg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Nút comment
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.comment, color: Colors.white),
              onPressed: () => _showCommentsSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

// BOTTOM SHEET COMMENT
class CommentBottomSheet extends StatefulWidget {
  final String bookId;
  const CommentBottomSheet({super.key, required this.bookId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> comments = [];
  bool isLoading = false;

  String currentUsername=''; // 👈 tạm fix, sau này lấy từ login

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchComments();
      getCurrentUsername();
    });
    
  }

  Future<void> fetchComments() async {
    try {
      setState(() => isLoading = true);
      final response = await ApiService.getComments(widget.bookId);
      setState(() {
        comments = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      });
    }
  }
  Future<void> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? 'Ẩn danh'; // lấy username từ SharedPreferences
    });
  }

  Future<void> addComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    try {
      await ApiService.addComment(widget.bookId, content);
      _controller.clear();
      await fetchComments(); // reload comments
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      });
    }
  }

  Future<void> deleteComment(String bookId, String commentId) async {
    try {
      await ApiService.deleteComment(bookId, commentId);
      await fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa bình luận")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Bình luận",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: CommentListWidget(
                comments: comments,
                isLoading: isLoading,
                currentUsername: currentUsername, // 👈 truyền username
                bookId: widget.bookId,
                deleteComment: deleteComment,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Nhập bình luận...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFB71C1C)),
                  onPressed: addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
