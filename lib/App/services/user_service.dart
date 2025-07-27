import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blogs_pado/App/models/user_models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<bool> isFollowing(String currentUid, String targetUid) async {
    final doc = await _firestore.collection('users').doc(currentUid).get();
    final following = List<String>.from(doc.data()?['following'] ?? []);
    return following.contains(targetUid);
  }


  Future<void> followUser(String currentUid, String targetUid) async {
    if (currentUid == targetUid) return;

    await _firestore.collection('users').doc(currentUid).update({
      'following': FieldValue.arrayUnion([targetUid])
    });

    await _firestore.collection('users').doc(targetUid).update({
      'followers': FieldValue.arrayUnion([currentUid])
    });
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    await _firestore.collection('users').doc(currentUid).update({
      'following': FieldValue.arrayRemove([targetUid])
    });

    await _firestore.collection('users').doc(targetUid).update({
      'followers': FieldValue.arrayRemove([currentUid])
    });
  }

  Future<void> toggleFollow(String currentUid, String targetUid) async {
    final doc = await _firestore.collection('users').doc(currentUid).get();
    final following = List<String>.from(doc.data()?['following'] ?? []);

    if (following.contains(targetUid)) {
      await unfollowUser(currentUid, targetUid);
    } else {
      await followUser(currentUid, targetUid);
    }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map(
          (snap) => snap.docs.map((doc) => UserModel.fromMap(doc.data())).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> uids) async {
    List<Map<String, dynamic>> users = [];

    for (String uid in uids) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['uid'] = uid;
        users.add(data);
      }
    }
    return users;
  }
}
