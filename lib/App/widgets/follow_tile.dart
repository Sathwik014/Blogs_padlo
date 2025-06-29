import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialIsFollowing != null) {
      isFollowing = widget.initialIsFollowing!;
    } else {
      checkFollowingStatus();
    }
  }

  Future<void> checkFollowingStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    final following = List<String>.from(doc.data()?['following'] ?? []);
    setState(() {
      isFollowing = following.contains(widget.targetUserId);
    });
  }

  Future<void> toggleFollow() async {
    setState(() => isLoading = true);
    final usersRef = FirebaseFirestore.instance.collection('users');

    final userDoc = usersRef.doc(currentUserId);
    final targetDoc = usersRef.doc(widget.targetUserId);

    final batch = FirebaseFirestore.instance.batch();

    if (isFollowing) {
      batch.update(userDoc, {
        'following': FieldValue.arrayRemove([widget.targetUserId])
      });
      batch.update(targetDoc, {
        'followers': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      batch.update(userDoc, {
        'following': FieldValue.arrayUnion([widget.targetUserId])
      });
      batch.update(targetDoc, {
        'followers': FieldValue.arrayUnion([currentUserId])
      });
    }

    await batch.commit();

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
      onPressed: isLoading ? null : toggleFollow,
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
