import 'package:flutter/material.dart';
import 'package:blogs_pado/App/models/user_models.dart';
import 'package:blogs_pado/App/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  void loadAllUsers() {
    _userService.getAllUsers().listen((userList) {
      _users = userList;
      notifyListeners();
    });
  }

  Future<void> followUser(String currentUid, String targetUid) async {
    await _userService.followUser(currentUid, targetUid);
    notifyListeners();
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    await _userService.unfollowUser(currentUid, targetUid);
    notifyListeners();
  }

  Future<void> toggleFollow(String currentUid, String targetUid) async {
    await _userService.toggleFollow(currentUid, targetUid);
    notifyListeners();
  }

  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    return await _userService.getUsersByIds(ids);
  }
}
