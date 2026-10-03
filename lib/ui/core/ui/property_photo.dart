import 'package:flutter/material.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Same tag on the list card, the detail and the full-screen viewer: Flutter
/// animates the photo "flying" between them.
Object propertyPhotoHeroTag(int propertyId) => 'property-photo-$propertyId';

/// Listing photo with loading and unavailable states (docs/estados.md).
class PropertyPhoto extends StatelessWidget {
  const PropertyPhoto({
    super.key,
    required this.url,
    required this.title,
    this.heroTag,
    this.fit = BoxFit.cover,
  });

  final String url;
  final String title;
  final Object? heroTag;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final heroTag = this.heroTag;
    final image = Image.network(
      url,
      fit: fit,
      semanticLabel: 'Foto de $title',
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const _PhotoPlaceholder(icon: Icons.image_outlined),
      errorBuilder: (context, error, stackTrace) => const _PhotoPlaceholder(
        icon: Icons.home_outlined,
        label: 'Foto indisponível',
      ),
    );
    return heroTag == null ? image : Hero(tag: heroTag, child: image);
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
      // Scales down instead of overflowing: the photo can be tiny, e.g. in
      // the middle of a Hero flight.
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
      ),
    );
  }
}
