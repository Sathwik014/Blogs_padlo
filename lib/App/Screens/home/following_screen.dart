import 'package:blogs_pado/App/widgets/follow_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FollowingScreen extends StatefulWidget {
  final List<String> userIds;
  final String title;

  const FollowingScreen({
    super.key,
    required this.userIds,
    required this.title,
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  Future<List<Map<String, dynamic>>> fetchUsers(List<String> uids) async {
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> users = [];

    for (String uid in uids) {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['uid'] = uid;
        users.add(data);
      }
    }
    return users;
  }

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers(widget.userIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, index) {
              final user = users[index];
              final uid = user['uid'];

              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (user['profilePicUrl'] != null &&
                          user['profilePicUrl'].toString().isNotEmpty)
                          ? CachedNetworkImageProvider(user['profilePicUrl'])
                          : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                    ),
                    title: Text(user['username'] ?? 'Unnamed'),
                    subtitle: Text(user['email'] ?? ''),
                    trailing: FollowButton(targetUserId: uid),
                  ),
                  Divider(height: 1,)
                ],
              );
            },
          );
        },
      ),
    );
  }
}
