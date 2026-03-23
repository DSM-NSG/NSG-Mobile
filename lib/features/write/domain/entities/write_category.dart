import 'package:flutter/material.dart';

class WriteCategory {
  final String label;
  final IconData icon;
  final String route;
  final String? imagePath;

  const WriteCategory({
    required this.label,
    required this.icon,
    required this.route,
    this.imagePath,
  });
}
