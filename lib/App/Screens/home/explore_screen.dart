import 'package:blogs_pado/App/Screens/blog/Create_edit_Blog.dart';
import 'package:blogs_pado/App/Screens/home/following_blogs.dart';
import 'package:blogs_pado/App/Screens/home/profile_screen.dart';
import 'package:blogs_pado/App/models/blog_model.dart';
import 'package:blogs_pado/App/services/blog_service.dart';
import 'package:blogs_pado/App/widgets/blog_tile.dart';
import 'package:blogs_pado/App/widgets/settings.dart';
import 'package:blogs_pado/Authentication/services/UserDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  String selectedCategory = 'All';
  String blogView = 'All Blogs'; // Toggle between "All Blogs" and "My Blogs"
  final List<String> categories = ['All', 'Interns', 'Academics', 'Campus', 'Tech', 'Clubs'];

  @override
  void initState() {
    super.initState();
    checkUserDetails();
  }

  Future<void> checkUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists || doc.data()?['username'] == null || doc.data()?['mobileNo'] == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserDetailsForm()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildHomeContent(),
      FollowingBlogsPage(),
      Newblog(), // Write New Blog placeholder
      Container(), // Calendar
      ProfileScreen(), // Profile
    ];

    return SafeArea(
      child:Scaffold(
       appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Blogs Padlo Guyzz',
          style: TextStyle(fontSize: 30, fontFamily: 'Bilbo',fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Logout",
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close loading dialog
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout failed: $e")),
                );
              }
            },
          ),

          Padding(
            padding: EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),

      body: pages[_selectedIndex],

      bottomNavigationBar: GNav(
        onTabChange: (index) async {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Newblog()),
           );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        color: Colors.white,
        backgroundColor: Colors.black,
        activeColor: Colors.white,
        tabBackgroundColor: Colors.grey.shade800,
        gap: 15,
        tabs: const [
          GButton(icon: Icons.home_outlined),
          GButton(icon: Icons.favorite,iconActiveColor: Colors.red,),
          GButton(icon: Icons.add_box_outlined,),
          GButton(icon: Icons.notifications_none_sharp,iconActiveColor: Colors.pink,),
          GButton(icon: Icons.account_circle_outlined,),
        ],
      ),
    ),
    );
  }

  Widget buildHomeContent() {

    final Stream<List<BlogModel>> blogStream = BlogService().getAllBlogsStream();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search Field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search blogs...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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

          // 📋 Blog List
          Expanded(
            child: StreamBuilder<List<BlogModel>>(
              stream: blogStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final allBlogs = snapshot.data!.where((blog) {
                  final matchesSearch = blog.title.toLowerCase().contains(searchText);
                  final matchesCategory = selectedCategory == 'All' || blog.category.toLowerCase() == selectedCategory.toLowerCase();
                  final isByOtherUser = blog.authorId != userId;
                  return matchesSearch && matchesCategory && isByOtherUser;
                }).toList();

                if (allBlogs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No blogs found.\nTry changing filters!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: allBlogs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      child: BlogTile(blog: allBlogs[index]),
                    );
                  },
                );
              },
            )
          ),
        ],
      );
  }
}
