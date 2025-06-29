import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../services/blog_service.dart';

class BlogProvider with ChangeNotifier {
  final BlogService _blogService = BlogService();

  List<BlogModel> _blogs = [];
  List<BlogModel> get blogs => _blogs;

  // 🔁 Listen to all blogs
  Stream<QuerySnapshot> get exploreBlogsStream {
    return FirebaseFirestore.instance
        .collection('blogs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 📥 Load blogs only from followed users
  void loadFollowingBlogs(List<String> followingUIDs) {
    _blogService.getAllBlogs().listen((blogList) {
      _blogs = blogList
          .where((blog) => followingUIDs.contains(blog.authorId))
          .toList();
      notifyListeners();
    });
  }

  // 📌 Create a blog
  Future<void> createBlog(BlogModel blog) async {
    await _blogService.createBlog(blog);
  }

  // 🗑 Delete blog
  Future<void> deleteBlog(String blogId) async {
    await _blogService.deleteBlog(blogId);
  }

  // 👍 Toggle like
  Future<void> toggleLike(String blogId, String uid) async {
    await _blogService.toggleLike(blogId, uid);
  }
}
