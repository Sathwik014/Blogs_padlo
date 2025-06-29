import 'package:flutter/material.dart';

///  Custom Button Widget used in login/register screens
/// It takes a text label and a callback function (onTap)
class MyButton extends StatelessWidget {
  final String text;               // Button label
  final VoidCallback? onTap;      // Function to execute on tap

  const MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap function when the button is pressed
      child: Container(
        padding: const EdgeInsets.all(20),  // Padding inside the button
        margin: const EdgeInsets.symmetric(horizontal: 25), // Margin around the button
        decoration: BoxDecoration(
          color: Colors.green, // Background color of the button
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,            // Text color
              fontWeight: FontWeight.bold,    // Bold text
              fontSize: 16,                   // Font size
            ),
          ),
        ),
      ),
    );
  }
}
