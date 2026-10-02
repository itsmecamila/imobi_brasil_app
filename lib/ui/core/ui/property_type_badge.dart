import 'package:flutter/material.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Yellow "VENDA" / "ALUGUEL" tag; dark text keeps contrast on accentYellow.
class PropertyTypeBadge extends StatelessWidget {
  const PropertyTypeBadge({super.key, required this.type});

  final PropertyType type;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      PropertyType.sale => 'Venda',
      PropertyType.rent => 'Aluguel',
    };
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.accentYellow,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
