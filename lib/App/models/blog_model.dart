import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String blogId;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final DateTime timestamp;
  final List<String> likes;
  final bool pinned;
  final String category;
  final String imageUrl;
  final String authorPhotoUrl;

  final List<dynamic> content;

  BlogModel({
    required this.blogId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.description,
    required this.timestamp,
    required this.likes,
    required this.pinned,
    required this.category,
    required this.imageUrl,
    required this.authorPhotoUrl,
  });

  factory BlogModel.fromMap(String id, Map<String, dynamic> data) {
    print("Parsing BlogModel from Firestore: $data");
    return BlogModel(
      blogId: id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      title: data['title'] ?? 'Untitled',
      content: data['content'] ?? [],
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: List<String>.from(data['likes'] ?? []),
      pinned: data['pinned'] ?? false,
      category: data['category'] ?? 'work',
      imageUrl: data['imageUrl'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'title': title,
      'description': description,
      'content': content,
      'timestamp': timestamp,
      'pinned': pinned,
      'category': category,
      'likes': likes,
      'imageUrl': imageUrl ?? '',
    };
  }
}
