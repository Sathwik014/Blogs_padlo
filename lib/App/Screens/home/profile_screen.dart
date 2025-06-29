import 'package:blogs_pado/App/Screens/home/following_screen.dart';
import 'package:blogs_pado/App/models/blog_model.dart';
import 'package:blogs_pado/App/widgets/blog_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  Future<List<BlogModel>> _loadUserBlogs(List<String> blogIds) async {
    final blogs = <BlogModel>[];

    for (final id in blogIds) {
      final doc = await FirebaseFirestore.instance.collection('blogs').doc(id).get();
      if (doc.exists) {
        try {
          blogs.add(BlogModel.fromMap(doc.id, doc.data()!));
        } catch (e) {
          debugPrint('Error loading blog $id: $e');
        }
      }
    }

    return blogs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text("User not found."));

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final blogIds = List<String>.from(userData['blogs'] ?? []);
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return Column(
            children: [
              const SizedBox(height: 10),
              // 🔵 Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['username'] ?? 'No Name',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text("Hyderabad", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FollowingScreen(
                                          userIds: followers,
                                          title: "Followers",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        "${followers.length}",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const Text("Followers"),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FollowingScreen(
                                          userIds: following,
                                          title: "Following",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        "${following.length}",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const Text("Following"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              // 🔘 Buttons
              Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Optional: implement follow logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Follow",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Optional: implement message
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Message",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),

              const Divider(height: 20),

              // 📃 My Blogs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("My Blogs",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: FutureBuilder<List<BlogModel>>(
                  future: _loadUserBlogs(blogIds),
                  builder: (context, blogSnapshot) {
                    if (blogSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (blogSnapshot.hasError) {
                      return Center(child: Text("Error: ${blogSnapshot.error}"));
                    }

                    final blogs = blogSnapshot.data ?? [];

                    if (blogs.isEmpty) {
                      return const Center(child: Text("No blogs posted yet."));
                    }

                    return ListView.builder(
                      itemCount: blogs.length,
                      itemBuilder: (context, index) {
                        return BlogTile(blog: blogs[index], showOptions: true);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
