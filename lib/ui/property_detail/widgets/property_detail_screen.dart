import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/property_photo.dart';
import 'package:imobi_app/ui/core/ui/property_type_badge.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';
import 'package:imobi_app/ui/property_detail/view_models/property_detail_view_model.dart';
import 'package:imobi_app/ui/property_detail/widgets/contact_options.dart';
import 'package:imobi_app/utils/formatters.dart';
import 'package:provider/provider.dart';

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyDetailViewModel>();
    final property = viewModel.property;

    if (viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Imóvel')),
        body: const StateMessage.loading(message: 'Carregando imóvel…'),
      );
    }
    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Imóvel')),
        body: StateMessage(
          icon: Icons.home_work_outlined,
          message: 'Este imóvel não está mais disponível.',
          hint: 'Ele pode ter sido removido ou o link está desatualizado.',
          action: FilledButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('Voltar para a lista'),
          ),
        ),
      );
    }
    return _DetailView(
      property: property,
      onContact: () => showContactOptions(context, viewModel),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView({required this.property, required this.onContact});

  final Property property;
  final VoidCallback onContact;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  static const _expandedHeight = 240.0;

  late final _scrollController = ScrollController()..addListener(_onScroll);
  bool _collapsed = false;

  /// The photo has turned into the green bar: show the title, drop the
  /// dark circles that only exist for contrast over the photo.
  void _onScroll() {
    final collapsed =
        _scrollController.offset > _expandedHeight - kToolbarHeight - 8;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    // Dark translucent backing keeps the white icons readable over any photo.
    final buttonBacking = _collapsed
        ? Colors.transparent
        : AppColors.text.withValues(alpha: 0.58);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _expandedHeight,
            leading: Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: buttonBacking),
                tooltip: 'Voltar',
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              ),
            ),
            title: _collapsed ? Text(property.title) : null,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: buttonBacking,
                    minimumSize: const Size(48, 40),
                  ),
                  onPressed: () => context.go(Routes.editProperty(property.id)),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Only tappable while expanded: once it is the green bar,
                  // tapping the title area must not open the photo.
                  Semantics(
                    button: !_collapsed,
                    hint: 'Toque para ampliar',
                    child: GestureDetector(
                      onTap: _collapsed
                          ? null
                          : () => context.go(Routes.propertyPhoto(property.id)),
                      child: PropertyPhoto(
                        url: property.photoUrl,
                        title: property.title,
                        heroTag: propertyPhotoHeroTag(property.id),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: PropertyTypeBadge(type: property.type),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _DetailContent(property: property)),
        ],
      ),
      bottomNavigationBar: _ContactBar(onContact: widget.onContact),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            formatPrice(property),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${property.neighborhood}, ${property.city}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Features(property: property),
          if (property.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Descrição', style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              property.description,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _Feature(Icons.bed_outlined, formatBedrooms(property.bedrooms)),
            const SizedBox(width: 8),
            _Feature(
              Icons.bathtub_outlined,
              formatBathrooms(property.bathrooms),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Feature(
              Icons.directions_car_outlined,
              formatParkingSpaces(property.parkingSpaces),
            ),
            const SizedBox(width: 8),
            _Feature(Icons.square_foot, formatArea(property.area)),
          ],
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              // Decorative: the text next to it already says it all.
              ExcludeSemantics(
                child: Icon(icon, size: 20, color: AppColors.brand500),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactBar extends StatelessWidget {
  const _ContactBar({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: FilledButton(
            onPressed: onContact,
            child: const Text('Entrar em Contato'),
          ),
        ),
      ),
    );
  }
}
