import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/destructive_button.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';
import 'package:imobi_app/ui/core/ui/success_snack_bar.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_skeleton.dart';
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

  /// Erases edits and new listings, so it asks first. Afterwards the list
  /// shows the sample data from the top, with search and filter cleared.
  Future<void> _restoreSample() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar dados de exemplo?'),
        content: const Text(
          'As edições e os imóveis cadastrados serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          DestructiveButton(
            label: 'Restaurar',
            icon: Icons.restore,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) await _runRestore();
  }

  Future<void> _runRestore() async {
    final messenger = ScaffoldMessenger.of(context);
    final restored = await context
        .read<PropertyListViewModel>()
        .restoreSample();
    if (!mounted) return;

    if (restored) {
      _searchController.clear();
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      messenger.showSnackBar(successSnackBar('Dados de exemplo restaurados'));
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Não foi possível restaurar agora.'),
          action: SnackBarAction(label: 'Atualizar', onPressed: _runRestore),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyListViewModel>();
    final isLoaded = !viewModel.isLoading && !viewModel.hasError;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Quick return: hides on scroll down, comes back whole on scroll up.
          // Sized by its content, so larger system fonts grow the header
          // instead of spilling over the list.
          SliverFloatingHeader(
            child: Column(
              children: [
                _BrandBar(
                  onRestore: _restoreSample,
                  canRestore: !viewModel.isLoading,
                ),
                _SearchAndFilter(
                  viewModel: viewModel,
                  searchController: _searchController,
                ),
              ],
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
      return const [SliverToBoxAdapter(child: PropertyListSkeleton())];
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

/// The green bar: brand, title, user and "Sair". Built by hand instead of an
/// AppBar because an AppBar has a fixed height.
class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.onRestore, required this.canRestore});

  final VoidCallback onRestore;
  final bool canRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = context.watch<AuthRepository>().user?.name;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.appBarTheme.systemOverlayStyle!,
      child: ColoredBox(
        color: AppColors.brand600,
        child: Padding(
          // The status bar sits on the green, as it did with the AppBar.
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + 12,
            8,
            12,
          ),
          child: Row(
            children: [
              // Original brand icon on a white tile: green on green would
              // vanish.
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Imóveis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (userName != null)
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              _MoreMenu(onRestore: onRestore, canRestore: canRestore),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MenuAction { restore, signOut }

/// Rarely used actions behind "Mais opções", each with a visible label.
/// Signing out asks first (a stray tap in the corner should not end the
/// session), then shows "Saindo…" while the session closes.
class _MoreMenu extends StatefulWidget {
  const _MoreMenu({required this.onRestore, required this.canRestore});

  final VoidCallback onRestore;

  /// Off while listings load, so a restore never races the first load.
  final bool canRestore;

  @override
  State<_MoreMenu> createState() => _MoreMenuState();
}

class _MoreMenuState extends State<_MoreMenu> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    final auth = context.read<AuthRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Você precisará entrar de novo para ver os imóveis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);
    // No navigation here: the router sends a signed-out user to the login.
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSigningOut) {
      return Semantics(
        label: 'Saindo…',
        liveRegion: true,
        child: const SizedBox.square(
          dimension: 48,
          child: Center(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Mais opções',
      iconColor: Colors.white,
      onSelected: (action) => switch (action) {
        _MenuAction.restore => widget.onRestore(),
        _MenuAction.signOut => _signOut(),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MenuAction.restore,
          enabled: widget.canRestore,
          child: const _MenuItem(
            icon: Icons.restore,
            label: 'Restaurar dados de exemplo',
          ),
        ),
        const PopupMenuItem(
          value: _MenuAction.signOut,
          child: _MenuItem(icon: Icons.logout, label: 'Sair'),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Flexible(child: Text(label)),
      ],
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.viewModel,
    required this.searchController,
  });

  final PropertyListViewModel viewModel;
  final TextEditingController searchController;

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

/// A filter label is never broken or cut ("Alugue/l" reads as a bug): with
/// large system fonts on narrow screens it shrinks just enough to fit. The
/// check mark stays, so the selection is not shown by color alone.
class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );
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
