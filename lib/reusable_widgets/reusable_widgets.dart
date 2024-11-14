import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget for displaying a logo image with fallback for errors.
Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white, // Logo color remains white by default
    errorBuilder: (context, error, stackTrace) {
      return Icon(Icons.error, size: 240, color: Colors.red); // Error icon color set to red
    },
  );
}

/// A reusable text field widget with configurable icon and password visibility.
TextField reusableTextField(
    String text,
    IconData icon,
    bool isPasswordType,
    TextEditingController controller, {
      Color iconColor = Colors.white70,
      Color fillColor = Colors.blueAccent,
      Function(String)? onChanged, // Added onChanged callback
    }) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white, // Cursor color remains white
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    onChanged: onChanged, // Pass the onChanged function to the TextField
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: iconColor, // Custom icon color passed as parameter
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: fillColor.withOpacity(0.3), // Custom fill color passed as parameter
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

/// A reusable button widget that accepts custom text, onTap functionality, and an optional icon.
Container reusableButton(
    BuildContext context, String buttonText, Function onTap,
    {IconData? icon, Color buttonColor = const Color(0xFFeb6958), Color textColor = Colors.white}) {
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
    ),
    child: ElevatedButton.icon(
      onPressed: () {
        onTap();
      },
      icon: icon != null ? Icon(icon, size: 20, color: textColor) : const SizedBox.shrink(),
      label: Text(
        buttonText,
        style: TextStyle(
          color: textColor, // Custom text color passed as parameter
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(370, 50)),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.black26;
          }
          return buttonColor; // Custom button color passed as parameter
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    ),
  );
}
