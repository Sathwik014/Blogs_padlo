import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/blog_model.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📝 Create Blog
  Future<void> createBlog(BlogModel blog) async {
    final ref = _firestore.collection('blogs').doc();
    final currentUser = FirebaseAuth.instance.currentUser;

    await ref.set({
      ...blog.toMap(),
      'authorId': currentUser?.uid,
      'authorName': currentUser?.displayName ?? 'Anonymous',
      'authorPhotoUrl': '', // or default asset if needed
    });
  }


  // ✏️ Edit Blog
  Future<void> updateBlog(String blogId, Map<String, dynamic> data) async {
    await _firestore.collection('blogs').doc(blogId).update(data);
  }

  // 🗑 Delete Blog
  Future<void> deleteBlog(String blogId) async {
    await _firestore.collection('blogs').doc(blogId).delete();
  }

  // 🔄 Toggle Like
  Future<void> toggleLike(String blogId, String uid) async {
    final ref = _firestore.collection('blogs').doc(blogId);
    final snapshot = await ref.get();
    final List likes = snapshot['likes'];

    if (likes.contains(uid)) {
      await ref.update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  // 📥 Get All Blogs
  Stream<List<BlogModel>> getAllBlogs() {
    return _firestore
        .collection('blogs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return BlogModel.fromMap(doc.id, data);
        }).toList());
  }

  // 📥 Get Blogs by Author UID (for profile)
  Stream<List<BlogModel>> getBlogsByUser(String uid) {
    return _firestore
        .collection('blogs')
        .where('authorId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return BlogModel.fromMap(doc.id, data);
        }).toList());
  }
}
