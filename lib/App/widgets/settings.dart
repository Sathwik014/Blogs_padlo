import 'package:blogs_pado/Authentication/services/UserDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Account settings'),
            onTap: () {;},
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: const Text('Saved'),
            onTap: () {;},
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Your Activity'),
            onTap: () {;},
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Details'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserDetailsForm()),
              );
            },
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('logout'),
            onTap: () async {
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
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}
