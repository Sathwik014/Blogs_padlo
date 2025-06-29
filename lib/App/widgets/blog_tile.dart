import 'package:blogs_pado/App/Screens/blog/blog_detail_screen.dart';
import 'package:blogs_pado/App/Screens/blog/edit_blog_screen.dart';
import 'package:blogs_pado/App/Screens/comments/comment_screen.dart';
import 'package:blogs_pado/App/models/blog_model.dart';
import 'package:blogs_pado/App/widgets/follow_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BlogTile extends StatefulWidget {
  final BlogModel blog;
  final bool showOptions;
  const BlogTile({super.key, required this.blog, this.showOptions = false});

  @override
  State<BlogTile> createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> {
  late bool isLiked;
  late String currentUserId;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    isLiked = widget.blog.likes.contains(currentUserId);
  }

  void toggleLike() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final blogRef =
    FirebaseFirestore.instance.collection('blogs').doc(widget.blog.blogId);
    final updatedLikes = isLiked
        ? widget.blog.likes.where((id) => id != uid).toList()
        : [...widget.blog.likes, uid];

    await blogRef.update({'likes': updatedLikes});

    setState(() {
      isLiked = !isLiked;
      widget.blog.likes
        ..clear()
        ..addAll(updatedLikes);
    });
  }

  void deleteBlog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Blog?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final blogId = widget.blog.blogId;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final blogRef = FirebaseFirestore.instance.collection('blogs').doc(blogId);

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.delete(blogRef);
          transaction.update(userRef, {
            'blogs': FieldValue.arrayRemove([blogId])
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Blog deleted")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting blog: $e")),
          );
        }
      }
    }
  }


  void openEditBlog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditBlogPage(blog: widget.blog)),
    );
  }

  void openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: widget.blog)),
    );
  }

  void openComments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentScreen(
          blogId: widget.blog.blogId,
          blogAuthorId: widget.blog.authorId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 6, offset: const Offset(0, 4),),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 Author info + dropdown menu + follow button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.blog.authorName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                FollowButton(targetUserId: widget.blog.authorId),
                if (widget.showOptions)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Edit') openEditBlog(context);
                      if (value == 'Delete') deleteBlog(context);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            /// 📝 Title & Description
            Text(widget.blog.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(widget.blog.description, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 6),

            /// 📊 Footer actions
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 16,
                  ),
                  onPressed: toggleLike,
                ),
                Text(widget.blog.likes.length.toString()),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => openComments(context),
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      FutureBuilder<int>(
                        future: _fetchCommentCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("...");
                          }
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text("${snapshot.data ?? 0}"),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                  Icon(
                    widget.blog.pinned ? Icons.local_fire_department_sharp : Icons.local_fire_department_outlined,
                    color: Colors.orange[600],
                    size: 16,
                  ),
                const SizedBox(width: 8),
                Text("3"),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_outline_sharp, color: Colors.white, size: 18),
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<int> _fetchCommentCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blog.blogId)
        .collection('comments')
        .get();
    return snapshot.size;
  }
}
