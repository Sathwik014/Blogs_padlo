import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blogs_pado/App/models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 💬 Add Comment
  Future<void> addComment(String blogId, CommentModel comment) async {
    final ref = _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .doc(comment.commentId);

    await ref.set(comment.toMap());
  }

  // ❌ Delete Comment
  Future<void> deleteComment(String blogId, String commentId) async {
    await _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // 🗂️ Get Comments for a Blog
  Stream<List<CommentModel>> getComments(String blogId) {
    return _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CommentModel.fromMap(doc.data())).toList());
  }
}
