import 'package:flutter/material.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Confirmation after a save: the check icon makes success recognizable at a
/// glance, apart from error messages.
SnackBar successSnackBar(String message) => SnackBar(
  content: Row(
    children: [
      const Icon(Icons.check_circle_outline, color: AppColors.brand50),
      const SizedBox(width: 8),
      Expanded(child: Text(message)),
    ],
  ),
);
