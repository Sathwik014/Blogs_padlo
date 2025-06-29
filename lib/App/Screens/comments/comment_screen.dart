import 'package:blogs_pado/App/widgets/comment_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blogs_pado/App/models/comment_model.dart';
import '../../services/comment_service.dart';
import 'package:uuid/uuid.dart';

class CommentScreen extends StatefulWidget {
  final String blogId;
  final String blogAuthorId;
  const CommentScreen({super.key, required this.blogId, required this.blogAuthorId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final commentController = TextEditingController();
  final commentService = CommentService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return SafeArea(child:Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: commentService.getComments(widget.blogId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final canDelete = comment.commenterId == user.uid || user.uid == widget.blogAuthorId;
                    return CommentTile(comment: comment, canDelete: canDelete);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(hintText: "Write a comment..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    final username = userDoc['username'] ?? 'Anonymous';
                    final photoUrl = userDoc['profilePicUrl'] ?? '';

                    final comment = CommentModel(
                      commentId: const Uuid().v4(),
                      commenterId: user.uid,
                      commenterName: username,
                      commenterPhotoUrl: photoUrl,
                      content: commentController.text.trim(),
                      timestamp: DateTime.now(),
                    );

                    await commentService.addComment(widget.blogId, comment);
                    commentController.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    ),
    );
  }
}
