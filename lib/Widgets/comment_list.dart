import 'package:flutter/material.dart';

class CommentListWidget extends StatelessWidget {
  final List<dynamic> comments;
  final bool isLoading;
  final String currentUsername; // 👈 username của người đăng nhập
  final String bookId; // 👈 id sách
  final Future<void> Function(String bookId, String commentId) deleteComment;

  const CommentListWidget({
    Key? key,
    required this.comments,
    required this.isLoading,
    required this.currentUsername,
    required this.bookId,
    required this.deleteComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (comments.isEmpty) {
      return const Center(child: Text("Chưa có bình luận nào."));
    }

    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final cmt = comments[index];
        final username = cmt['username'] ?? 'Ẩn danh';
        final commentId = cmt['_id'] ?? ''; // 👈 id của comment (tùy backend)

        bool canDelete =
            currentUsername == username || currentUsername == "QuocThai";
      
          

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(cmt['content'] ?? ''),
          trailing: canDelete
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Xác nhận"),
                        content: const Text(
                            "Bạn có chắc chắn muốn xóa bình luận này?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Hủy"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Xóa"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await deleteComment(bookId, commentId);
                    }
                  },
                )
              : null,
        );
      },
    );
  }
}
