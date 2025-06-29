import 'package:blogs_pado/Authentication/components/Button.dart';
import 'package:blogs_pado/Authentication/components/TextField.dart';
import 'package:blogs_pado/Authentication/services/UserDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../Components/ErrorMessage.dart';

class Register_Page extends StatelessWidget {
  final void Function()? onTap;

  Register_Page({super.key, required this.onTap});

  // Controllers to collect input
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Function to create a new user
  void registerUser(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      displayError(context, "Passwords do not match");
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserDetailsForm()),
        );
      }
    } catch (e) {
      displayError(context, 'Registration Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Animated logo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Lottie.asset('assets/animations/logo1.json', width: 300, height: 300),
            ),

            // Email input field
            MyTextField(
              controller: emailController,
              hintText: "Email",
              obscureText: false,
            ),
            const SizedBox(height: 10),

            // Password input field
            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 10),

            // Confirm password input
            MyTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: true,
            ),
            const SizedBox(height: 25),

            // Register button
            MyButton(text: "Register", onTap: () => registerUser(context)),
            const SizedBox(height: 15),

            // Switch to login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already a member?"),
                GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    " Login now",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
