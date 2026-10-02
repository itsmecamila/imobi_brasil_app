import 'package:flutter/material.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Listing photo with loading and unavailable states (docs/estados.md).
class PropertyPhoto extends StatelessWidget {
  const PropertyPhoto({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      semanticLabel: 'Foto de $title',
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const _PhotoPlaceholder(icon: Icons.image_outlined),
      errorBuilder: (context, error, stackTrace) => const _PhotoPlaceholder(
        icon: Icons.home_outlined,
        label: 'Foto indisponível',
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.icon, this.label});

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    return ColoredBox(
      color: AppColors.border,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.muted),
            if (label != null) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
