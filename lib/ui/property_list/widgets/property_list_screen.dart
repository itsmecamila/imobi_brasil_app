import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';
import 'package:imobi_app/ui/core/ui/success_snack_bar.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';
import 'package:provider/provider.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final _scrollController = ScrollController();
  late final _searchController = TextEditingController(
    text: context.read<PropertyListViewModel>().query,
  );

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// After a listing is created here: make sure it is visible (search and
  /// filter are cleared only if they hide it) and scroll to the top, where new
  /// listings go. The create screen already confirmed the save; the message
  /// is replaced only to explain a cleared search or filter.
  Future<void> _openCreate() async {
    final created = await context.push<Property>(Routes.newProperty);
    if (created == null || !mounted) return;

    final cleared = context.read<PropertyListViewModel>().reveal(created);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    if (!cleared) return;

    _searchController.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        successSnackBar(
          'Imóvel cadastrado. Busca e filtro limpos para mostrá-lo.',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyListViewModel>();
    final isLoaded = !viewModel.isLoading && !viewModel.hasError;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            // Quick return: hides on scroll down, comes back whole on scroll up.
            floating: true,
            snap: true,
            // More air around the brand tile and title (the default bar is
            // 56 high and the tile sat too close to its edges).
            toolbarHeight: 68,
            titleSpacing: 16,
            title: const _BrandTitle(),
            bottom: _SearchAndFilter(
              viewModel: viewModel,
              searchController: _searchController,
            ),
          ),
          ..._content(context, viewModel),
        ],
      ),
      // Only once listings are loaded: a new id depends on them.
      floatingActionButton: isLoaded
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar imóvel'),
            )
          : null,
    );
  }

  List<Widget> _content(BuildContext context, PropertyListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: StateMessage.loading(message: 'Carregando imóveis…'),
        ),
      ];
    }
    if (viewModel.hasError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: StateMessage(
            icon: Icons.cloud_off_outlined,
            iconColor: AppColors.danger,
            message: 'Não foi possível carregar os imóveis agora.',
            hint: 'Verifique a conexão e tente de novo.',
            action: FilledButton.icon(
              onPressed: viewModel.load,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ),
        ),
      ];
    }
    if (viewModel.hasNoProperties) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: StateMessage(
            icon: Icons.home_work_outlined,
            message: 'Nenhum imóvel cadastrado ainda.',
          ),
        ),
      ];
    }

    final properties = viewModel.visibleProperties;
    if (properties.isEmpty) {
      final query = viewModel.query.trim();
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: StateMessage(
            icon: Icons.search_off,
            message: query.isEmpty
                ? 'Nenhum imóvel encontrado com esse filtro.'
                : 'Nenhum imóvel encontrado para "$query".',
            hint: 'Tente outro termo ou mude o filtro.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        // Bottom room for the floating button over the last card.
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        sliver: SliverList.separated(
          itemCount: properties.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final property = properties[index];
            return PropertyCard(
              property: property,
              onTap: () => context.go(Routes.property(property.id)),
            );
          },
        ),
      ),
    ];
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Original brand icon on a white tile: green on green would vanish.
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(9),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: SvgPicture.asset(
            'assets/images/imobibrasil-icon.svg',
            semanticsLabel: 'ImobiBrasil',
          ),
        ),
        const SizedBox(width: 14),
        const Text('Imóveis'),
      ],
    );
  }
}

class _SearchAndFilter extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAndFilter({
    required this.viewModel,
    required this.searchController,
  });

  final PropertyListViewModel viewModel;
  final TextEditingController searchController;

  @override
  Size get preferredSize => const Size.fromHeight(116);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            _SearchField(viewModel: viewModel, controller: searchController),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PropertyFilter>(
                segments: const [
                  ButtonSegment(
                    value: PropertyFilter.all,
                    label: _FilterLabel('Todos'),
                  ),
                  ButtonSegment(
                    value: PropertyFilter.sale,
                    label: _FilterLabel('Venda'),
                  ),
                  ButtonSegment(
                    value: PropertyFilter.rent,
                    label: _FilterLabel('Aluguel'),
                  ),
                ],
                selected: {viewModel.filter},
                onSelectionChanged: (selection) =>
                    viewModel.selectFilter(selection.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A filter label never wraps: a broken word ("Alugue/l") reads as a bug.
class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, maxLines: 1, softWrap: false);
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.viewModel, required this.controller});

  final PropertyListViewModel viewModel;
  final TextEditingController controller;

  void _clear() {
    controller.clear();
    viewModel.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: viewModel.search,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por título ou cidade',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: viewModel.query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Limpar busca',
                onPressed: _clear,
              ),
      ),
    );
  }
}
