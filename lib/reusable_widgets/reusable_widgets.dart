import 'dart:ui';
import 'package:flutter/material.dart';

/// A widget for displaying a logo image with fallback for errors.
Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
    errorBuilder: (context, error, stackTrace) {
      return Icon(Icons.error, size: 240, color: Colors.red);
    },
  );
}

/// A reusable text field widget with configurable icon and password visibility.
TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.blueAccent.withOpacity(0.3),
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
    {IconData? icon}) {
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
    ),
    child: ElevatedButton.icon(
      onPressed: () {
        onTap();
      },
      icon: icon != null ? Icon(icon, size: 20, color: Colors.white) : const SizedBox.shrink(),
      label: Text(
        buttonText,
        style: const TextStyle(
          color: Colors.white,
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
          return Color(0xFFeb6958);
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    ),
  );
}
