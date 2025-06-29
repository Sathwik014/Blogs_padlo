import 'package:blogs_pado/Authentication/Components/ErrorMessage.dart';
import 'package:blogs_pado/Authentication/services/google_auth.dart';
import 'package:flutter/material.dart';

class button extends StatelessWidget {
  final imageLink;
  final String Buttontext;
  const button({super.key,required this.Buttontext,required this.imageLink});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton.icon(
        onPressed: () async {
          final user = await signInWithGoogle();
          if (user == null) {
            displayError(context, "Google sign-in failed. Please try again.");
          }
        },
        icon: Image.asset(imageLink, height: 20,),
        label: Text( Buttontext,style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black12,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
