import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../Services/api_service.dart';
import '../../Widgets/comment_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final PdfViewerController _pdfController = PdfViewerController();

  int _initialPage = 1;
  int _currentPage = 1; // 🔹 Trang hiện tại
  bool _pdfReady = false;
  bool _askedJumpToPage = false; // Đảm bảo chỉ hỏi 1 lần
  bool _showPdfViewer = false; // Chỉ hiển thị PDF sau khi chọn
  int? _pendingJumpPage; // Trang cần chuyển sau khi PDF load

  @override
  void initState() {
    super.initState();
    checkIfLoved();
    _loadInitialReadingPage();
  }

  Future<void> checkIfLoved() async {
    try {
      final lovedBooks = await ApiService.fetchLovedBooks();
      final isInList = lovedBooks.any((book) {
        final id = book is Map ? (book['_id'] ?? book['id']) : null;
        return id == widget.bookId;
      });
      if (mounted) {
        setState(() => loved = isInList);
      }
    } catch (e) {
      // ignore lỗi
    }
  }

  Future<void> _loadInitialReadingPage() async {
    try {
      final list = await ApiService.getUserHistory();
      int last = 1;
      for (final item in list) {
        if (item is Map) {
          final dynamic book = item['bookId'];
          String? id;
          if (book is String) {
            id = book;
          } else if (book is Map) {
            id = book['_id'] ?? book['id'];
          }
          if (id == widget.bookId) {
            last = (item['lastPage'] ?? item['page'] ?? 1) is int
                ? (item['lastPage'] ?? item['page'] ?? 1) as int
                : int.tryParse('${item['lastPage'] ?? item['page'] ?? 1}') ?? 1;
            break;
          }
        }
      }

      if (mounted) {
        setState(() => _initialPage = last.clamp(1, 1000000));
      }

      if (_initialPage > 1 && !_askedJumpToPage) {
        _askedJumpToPage = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _askJumpToLastPage(_initialPage);
        });
      } else {
        // Nếu không cần hỏi thì hiển thị luôn PDF
        setState(() => _showPdfViewer = true);
      }
    } catch (e) {
      debugPrint('⚠️ _loadInitialReadingPage error: $e');
      setState(() => _showPdfViewer = true);
    }
  }

Future<void> _askJumpToLastPage(int page) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔖 Tiêu đề
            const Text(
              'Tiếp tục đọc?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 20),

            // 📄 Nội dung
            Text(
              'Bạn đã đọc tới trang $page.\nBạn có muốn chuyển tới trang đó không?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
             Text(
              'Nếu bạn không chọn, bạn sẽ bắt đầu từ trang đầu tiên.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // 👉 Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text(
                    'Không',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Có',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (mounted) {
    setState(() => _showPdfViewer = true);
    if (result == true) {
      if (_pdfReady) {
        _pdfController.jumpToPage(page);
      } else {
        _pendingJumpPage = page;
      }
    }
  }
}


  Future<void> toggleLove() async {
    try {
      final message = await ApiService.toggleBookLove(widget.bookId);
      if (mounted) {
        setState(() => loved = !loved);
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _saveProgress(int page) async {
    try {
      await ApiService.saveReadingProgress(widget.bookId, page);
      debugPrint('✅ Saved progress: book=${widget.bookId}, page=$page');
    } catch (e) {
      debugPrint('❌ Save progress error: $e');
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
          if (_showPdfViewer)
            SfPdfViewer.network(
              widget.pdfUrl,
              controller: _pdfController,
              pageLayoutMode: PdfPageLayoutMode.single,
              scrollDirection: PdfScrollDirection.horizontal,
              onDocumentLoaded: (details) {
                _pdfReady = true;
                // Nếu có trang cần chuyển thì chuyển ngay khi PDF đã load
                if (_pendingJumpPage != null) {
                  _pdfController.jumpToPage(_pendingJumpPage!);
                  _pendingJumpPage = null;
                }
              },
              onPageChanged: (PdfPageChangedDetails d) {
                _currentPage = d.newPageNumber;
              },
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Nút Back
          Positioned(
            top: 30,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black87,
              child: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                await _saveProgress(_currentPage); // 🔹 Lưu khi nhấn Back
                Navigator.pop(context, true);
              },
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

          // Logo giữa đỉnh + tiêu đề dạng viên thuốc
          Positioned(
            top: 24,
            left: MediaQuery.of(context).size.width / 2 - 110,
            child: Container(
              width: 220,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFB71C1C), width: 1.2),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  ClipOval(
                    child: Image.asset(
                      'assets/images/Logo_noText-removebg.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _MarqueeText(
                          text: widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFFB71C1C),
                          ),
                          velocity: 35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
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

// ===================== BOTTOM SHEET COMMENT =====================
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
  String currentUsername = '';

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
      if (mounted) {
        setState(() {
          comments = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
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
    if (mounted) {
      setState(() {
        currentUsername = prefs.getString('username') ?? 'Ẩn danh';
      });
    }
  }

  Future<void> addComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    try {
      await ApiService.addComment(widget.bookId, content);
      _controller.clear();
      await fetchComments();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      });
    }
  }

  Future<void> deleteComment(String bookId, String commentId) async {
    try {
      await ApiService.deleteComment(bookId, commentId);
      await fetchComments();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Đã xóa bình luận")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
                currentUsername: currentUsername,
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

// ===== MarqueeText Widget =====
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity; // pixels per second

  const _MarqueeText({
    required this.text,
    required this.style,
    this.velocity = 30,
    Key? key,
  }) : super(key: key);

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late double _textWidth;
  late double _containerWidth;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
  }

  void _startMarquee() async {
    final textKey = GlobalKey();
    final textWidget = Text(widget.text, style: widget.style, key: textKey);
    final textRender = (textWidget.key as GlobalKey).currentContext?.findRenderObject();
    _containerWidth = context.size?.width ?? 100;
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    _textWidth = painter.width;

    if (_textWidth > _containerWidth) {
      final duration = Duration(milliseconds: ((_textWidth + _containerWidth) / widget.velocity * 1000).toInt());
      _controller = AnimationController(vsync: this, duration: duration);
      _controller.repeat(reverse: true);
      _controller.addListener(() {
        final offset = (_controller.value * (_textWidth - _containerWidth));
        _scrollController.jumpTo(offset);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

