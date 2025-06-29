import 'package:blogs_pado/App/widgets/follow_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/blog_model.dart';
import '../comments/comment_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class BlogDetailScreen extends StatefulWidget {
  final BlogModel blog;
  const BlogDetailScreen({super.key, required this.blog});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late String currentUserId;
  late bool isLiked;
  late bool isAuthor;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    isLiked = widget.blog.likes.contains(user.uid);
    isAuthor = widget.blog.authorId == user.uid;
  }

  void toggleLike() async {
    final blogRef = FirebaseFirestore.instance.collection('blogs').doc(widget.blog.blogId);
    final updatedLikes = List<String>.from(widget.blog.likes);
    if (isLiked) {
      updatedLikes.remove(user.uid);
    } else {
      updatedLikes.add(user.uid);
    }
    await blogRef.update({'likes': updatedLikes});

    setState(() {
      isLiked = !isLiked;
    });
  }

  void deleteBlog() async {
    final blogRef = FirebaseFirestore.instance.collection('blogs').doc(widget.blog.blogId);
    await blogRef.delete();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Blog deleted")));
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yMMMd').format(widget.blog.timestamp);
    final quillController = quill.QuillController(
      document: quill.Document.fromJson(widget.blog.content),
      selection: const TextSelection.collapsed(offset: 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blog.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.blog.authorPhotoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(widget.blog.authorPhotoUrl)
                      : const AssetImage("assets/images/avatar.jpg") as ImageProvider,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.blog.authorName.isNotEmpty ? widget.blog.authorName : "Anonymous",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (widget.blog.authorId != currentUserId)
                  FollowButton(targetUserId: widget.blog.authorId),
              ],
            ),
            const SizedBox(height: 16),

           /* if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.blog.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[700],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),

            */

            const SizedBox(height: 16),

            quill.QuillEditor(
              controller: quillController,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: toggleLike,
                ),
                Text("${widget.blog.likes.length} likes", style: const TextStyle(color: Colors.white)),
              ],
            ),

            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentScreen(
                      blogId: widget.blog.blogId,
                      blogAuthorId: widget.blog.authorId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.comment, color: Colors.white70),
              label: const Text("View Comments", style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}