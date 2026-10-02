import 'package:flutter/material.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Full-area message for loading, empty and error states (docs/estados.md).
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required IconData this.icon,
    required this.message,
    this.iconColor = AppColors.muted,
    this.hint,
    this.action,
  });

  const StateMessage.loading({super.key, required this.message})
    : icon = null,
      iconColor = AppColors.muted,
      hint = null,
      action = null;

  final IconData? icon;
  final Color iconColor;
  final String message;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final hint = this.hint;
    final action = this.action;
    final textTheme = Theme.of(context).textTheme;

    // Centers itself, so it works inside slivers and straight in a body.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == null)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }
}
