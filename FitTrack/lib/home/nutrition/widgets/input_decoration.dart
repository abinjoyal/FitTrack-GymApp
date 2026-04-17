import 'package:flutter/material.dart';

InputDecoration customInputDecoration(String hint, String unit) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: Colors.white60,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),

    suffix: Text(
      unit,
      style: const TextStyle(color: Colors.white),
    ),

    filled: true,
    fillColor: const Color.fromARGB(255, 35, 57, 6),

    /// NORMAL BORDER
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Colors.white24,
        width: 1,
      ),
    ),

    /// FOCUS BORDER
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Color(0xFFC6F432),
        width: 1.5,
      ),
    ),
  );
}