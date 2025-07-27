import 'package:blogs_pado/App/Screens/home/explore_screen.dart';
import 'package:blogs_pado/Authentication/Screens/SwitchPage.dart';
import 'package:blogs_pado/Authentication/Screens/splashPage.dart';
import 'package:blogs_pado/Authentication/services/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BlogsLikho());
}

class BlogsLikho extends StatelessWidget {
  const BlogsLikho({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogs Likho',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Splash(); // Show splash during loading
          }
          if (snapshot.hasData) {
            return HomePage(); // Logged in
          } else {
            return const SwitchPages(); //  Not logged in
          }
        },
      ),
    );
  }
}