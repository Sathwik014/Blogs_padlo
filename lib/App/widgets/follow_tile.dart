import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogs_pado/App/services/user_service.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final bool? initialIsFollowing;

  const FollowButton({
    super.key,
    required this.targetUserId,
    this.initialIsFollowing,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final _userService = UserService();
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialIsFollowing != null) {
      isFollowing = widget.initialIsFollowing!;
    } else {
      _initFollowState();
    }
  }

  Future<void> _initFollowState() async {
    final result = await _userService.isFollowing(currentUserId, widget.targetUserId);
    if (mounted) {
      setState(() => isFollowing = result);
    }
  }

  Future<void> _handleToggleFollow() async {
    setState(() => isLoading = true);
    await _userService.toggleFollow(currentUserId, widget.targetUserId);
    if (mounted) {
      setState(() {
        isFollowing = !isFollowing;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == widget.targetUserId) return const SizedBox();

    return ElevatedButton(
      onPressed: isLoading ? null : _handleToggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.blue : Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
      child: isLoading
          ? const SizedBox(
        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Text(
        isFollowing ? "Following" : "Follow",
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}
