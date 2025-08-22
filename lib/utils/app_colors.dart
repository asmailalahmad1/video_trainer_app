// filename: lib/utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8F9FA);
  static const Color headline = Color(0xFF1A1A1A);
  static const Color primary = Color(0xFF2F80ED);
  static const Color secondary = Color(0xFF27AE60);
  static const Color notes = Color(0xFFF2C94C);
  static const Color cardBackground = Colors.white;

  // Status Colors
  static const Color statusWatched = Color(0xFF2196F3);
  static const Color statusAwaitingReview = Color(0xFFFF9800);
  static const Color statusReviewed = Color(0xFF4CAF50);

  static const List<Color> pieChartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFC107), // Amber
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF009688), // Teal
  ];
}
