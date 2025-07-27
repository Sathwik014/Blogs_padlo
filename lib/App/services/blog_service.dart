import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/blog_model.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📝 Create Blog
  Future<void> createBlogWithContent({
    required String title,
    required String description,
    required List<dynamic> contentJson,
    required String category,
    required DateTime blogDate,
    required bool isPinned,
    String? imageUrl,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();

    final blogData = {
      'title': title,
      'description': description,
      'content': contentJson,
      'timestamp': Timestamp.fromDate(blogDate),
      'category': category,
      'pinned': isPinned,
      'authorId': uid,
      'authorName': userDoc['username'] ?? 'Anonymous',
      'authorPhotoUrl': userDoc['profilePicUrl'] ?? '',
      'likes': [],
      'imageUrl': imageUrl ?? '',
    };

    final blogRef = await _firestore.collection('blogs').add(blogData);

    await _firestore.collection('users').doc(uid).update({
      'blogs': FieldValue.arrayUnion([blogRef.id])
    });
  }

 // Update Blog
  Future<void> updateBlog({
    required String blogId,
    required String title,
    required String description,
    required List<dynamic> contentJson,
    required String category,
    required DateTime blogDate,
    required bool isPinned,
  }) async {
    final updatedData = {
      'title': title,
      'description': description,
      'content': contentJson,
      'timestamp': Timestamp.fromDate(blogDate),
      'category': category,
      'pinned': isPinned,
      'lastEdited': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .update(updatedData);
  }

  // 🗑 Delete Blog
  Future<void> deleteBlogWithUserRef(String blogId, String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    final blogRef = _firestore.collection('blogs').doc(blogId);

    await _firestore.runTransaction((transaction) async {
      transaction.delete(blogRef);
      transaction.update(userRef, {
        'blogs': FieldValue.arrayRemove([blogId])
      });
    });
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