import 'package:flutter/material.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Button for actions that erase something ("Descartar", "Restaurar"): red
/// outline and icon, dark text, since white or red text would fail contrast
/// (decision in the imobibrasil-design skill).
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.danger),
      ),
      icon: Icon(icon, color: AppColors.danger),
      label: Text(label),
    );
  }
}
