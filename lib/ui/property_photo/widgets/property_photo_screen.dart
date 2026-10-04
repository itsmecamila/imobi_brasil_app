import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/load_states.dart';
import 'package:imobi_app/ui/core/ui/property_photo.dart';
import 'package:imobi_app/ui/property_detail/view_models/property_detail_view_model.dart';
import 'package:provider/provider.dart';

/// Full-screen photo with pinch zoom. It reuses the detail ViewModel: all it
/// needs is the listing (and the loading / not found states).
class PropertyPhotoScreen extends StatelessWidget {
  const PropertyPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyDetailViewModel>();
    final property = viewModel.property;

    // Opened straight from a link: the usual states, on the light theme.
    return LoadStates(
      title: 'Foto',
      loadingMessage: 'Carregando foto…',
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.retry,
      builder: (context) => property == null
          ? const ListingNotFound(title: 'Foto')
          : _FullScreenPhoto(property: property),
    );
  }
}

class _FullScreenPhoto extends StatelessWidget {
  const _FullScreenPhoto({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // The darkest brand token: pure black is not in the palette.
        backgroundColor: AppColors.text,
        body: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: PropertyPhoto(
                    url: property.photoUrl,
                    title: property.title,
                    heroTag: propertyPhotoHeroTag(property.id),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  tooltip: 'Fechar',
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                  ),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.property(property.id)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
