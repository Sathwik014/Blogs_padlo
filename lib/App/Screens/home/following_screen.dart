import 'package:blogs_pado/App/services/user_service.dart';
import 'package:blogs_pado/App/widgets/follow_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  final List<String> userIds; // List of followers/following
  final String title; // "Followers" or "Following"

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

  @override
  void initState() {
    super.initState();
    _usersFuture = UserService().getUsersByIds(widget.userIds);
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
                      backgroundImage: user['profilePicUrl'] != null &&
                          user['profilePicUrl'].toString().isNotEmpty
                          ? CachedNetworkImageProvider(user['profilePicUrl'])
                          : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                    ),
                    title: Text(user['username'] ?? 'Unnamed'),
                    subtitle: Text(user['email'] ?? ''),
                    trailing: FollowButton(targetUserId: uid),
                  ),
                  const Divider(height: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
