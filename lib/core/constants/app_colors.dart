import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF4F46E5);       // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Accent
  static const Color accent = Color(0xFF14B8A6);        // Teal
  static const Color accentLight = Color(0xFF5EEAD4);

  // Backgrounds — Light
  static const Color bgLight = Color(0xFFF0F4FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Backgrounds — Dark
  static const Color bgDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF22223B);

  // Text
  static const Color textPrimary = Color(0xFF1E1E3F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFF9CA3AF);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Category colours
  static const Color catFood = Color(0xFFF97316);       // Orange
  static const Color catTravel = Color(0xFF3B82F6);     // Blue
  static const Color catBills = Color(0xFFEF4444);      // Red
  static const Color catShopping = Color(0xFFA855F7);   // Purple
  static const Color catOthers = Color(0xFF6B7280);     // Gray

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return catFood;
      case 'travel':
        return catTravel;
      case 'bills':
        return catBills;
      case 'shopping':
        return catShopping;
      default:
        return catOthers;
    }
  }
}
