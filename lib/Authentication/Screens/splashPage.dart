import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:blogs_pado/Authentication/Screens/SwitchPage.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  double _opacity = 0;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 🌟 Trigger fade-in
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });

    // 🧭 Navigate after 2.5 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SwitchPages()),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark splash background
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2), // Smooth fade-in
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎞️ Lottie animation
              SizedBox(
                width: 250,
                height: 250,
                child: Lottie.asset(
                  'assets/animations/splash1.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              // 📝 App quote
              const Text(
                "Reels chodke zara blogs bhi deklo",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
