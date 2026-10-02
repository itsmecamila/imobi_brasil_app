import 'package:flutter/material.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/property_photo.dart';
import 'package:imobi_app/ui/core/ui/property_type_badge.dart';
import 'package:imobi_app/utils/formatters.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property, required this.onTap});

  final Property property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PropertyPhoto(url: property.photoUrl, title: property.title),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: PropertyTypeBadge(type: property.type),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          property.city,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(property),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
