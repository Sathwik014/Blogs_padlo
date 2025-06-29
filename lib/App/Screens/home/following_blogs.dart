import 'package:blogs_pado/App/models/blog_model.dart';
import 'package:blogs_pado/App/widgets/blog_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FollowingBlogsPage extends StatefulWidget {
  const FollowingBlogsPage({Key? key}) : super(key: key);

  @override
  State<FollowingBlogsPage> createState() => _FollowingBlogsPageState();
}

class _FollowingBlogsPageState extends State<FollowingBlogsPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Interns', 'Academics', 'Campus', 'Tech', 'Clubs'];
  List<String> followingUserIds = [];

  @override
  void initState() {
    super.initState();
    fetchFollowingUsers();
  }

  Future<void> fetchFollowingUsers() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = userDoc.data();
    if (data != null && data.containsKey('following')) {
      setState(() {
        followingUserIds = List<String>.from(data['following']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blogsRef = FirebaseFirestore.instance.collection('blogs').orderBy('timestamp', descending: true);
    final Stream<QuerySnapshot> blogStream = blogsRef.snapshots();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search blogs...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (val) => setState(() => searchText = val.toLowerCase()),
            ),
          ),

          // 🏷️ Category Tabs with Underline (like the image)
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;

                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = category),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isSelected)
                                Container(
                                  height: 2, width: 50, color: Colors.amber,
                                )
                              else
                                Container(height: 2, width: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 📝 Blog List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: blogStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final blogs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toLowerCase() ?? '';
                  final category = data['category']?.toLowerCase() ?? '';
                  final authorId = data['authorId'] ?? '';

                  final matchesSearch = title.contains(searchText);
                  final matchesCategory = selectedCategory == 'All' || category == selectedCategory.toLowerCase();
                  final isByFollowing = followingUserIds.contains(authorId);

                  return matchesSearch && matchesCategory && isByFollowing;
                }).toList();

                if (blogs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No blogs from followed users.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final doc = blogs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      child: BlogTile(
                        blog: BlogModel(
                          blogId: doc.id,
                          authorId: data['authorId'] ?? '',
                          authorName: data['authorName'] ?? 'Anonymous',
                          title: data['title'] ?? 'Untitled',
                          content: data['content'] ?? '',
                          description: data['description'] ?? '',
                          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                          likes: List<String>.from(data['likes'] ?? []),
                          pinned: data['pinned'] ?? false,
                          category: data['category'] ?? 'work',
                          imageUrl: data['imageUrl'] is List && data['imageUrl'].isNotEmpty
                              ? data['imageUrl'][0]
                              : (data['imageUrl'] ?? ''),
                          authorPhotoUrl: data['authorPhotoUrl'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
