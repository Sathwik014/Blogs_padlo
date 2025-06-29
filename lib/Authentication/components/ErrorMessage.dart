import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Function to display an error alert dialog with animation
/// Accepts context and an error message string to show
void displayError(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true, // Allow tap outside to close dialog
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.grey[900], // Optional: Match dark theme

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/error.json',
              width: 120,
              height: 120,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    },
  );
}
