import 'package:flutter/material.dart';

/// 🧩 Custom Text Field Widget used for login/register forms
/// Takes a controller, hint text, and a flag for password hiding
class MyTextField extends StatelessWidget {
  final TextEditingController controller; // Manages input text
  final String hintText;                  // Hint text inside the field
  final bool obscureText;                 // Whether the text should be hidden (e.g., password)

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Horizontal spacing around the text field
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,         // Controls the input text
        obscureText: obscureText,       // Hides the text if true (for passwords)
        decoration: InputDecoration(
          hintText: hintText,           // Placeholder text
          fillColor: Colors.white30,    // Background fill color (light transparent white)
          filled: true,                 // Enables background fill
          hintStyle: TextStyle(color: Colors.grey[500]), // Hint text color

          // Border when not focused
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),

          // Border when focused
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}
