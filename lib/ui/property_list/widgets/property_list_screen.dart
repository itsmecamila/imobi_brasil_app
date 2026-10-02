import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';
import 'package:provider/provider.dart';

class PropertyListScreen extends StatelessWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyListViewModel>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Quick return: hides on scroll down, comes back whole on scroll up.
            floating: true,
            snap: true,
            titleSpacing: 12,
            title: const _BrandTitle(),
            bottom: _SearchAndFilter(viewModel: viewModel),
          ),
          ..._content(context, viewModel),
        ],
      ),
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
          width: 34,
          height: 34,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: SvgPicture.asset(
            'assets/images/imobibrasil-icon.svg',
            semanticsLabel: 'ImobiBrasil',
          ),
        ),
        const SizedBox(width: 10),
        const Text('Imóveis'),
      ],
    );
  }
}

class _SearchAndFilter extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAndFilter({required this.viewModel});

  final PropertyListViewModel viewModel;

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
            _SearchField(viewModel: viewModel),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PropertyFilter>(
                segments: const [
                  ButtonSegment(
                    value: PropertyFilter.all,
                    label: Text('Todos'),
                  ),
                  ButtonSegment(
                    value: PropertyFilter.sale,
                    label: Text('Venda'),
                  ),
                  ButtonSegment(
                    value: PropertyFilter.rent,
                    label: Text('Aluguel'),
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

class _SearchField extends StatefulWidget {
  const _SearchField({required this.viewModel});

  final PropertyListViewModel viewModel;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final _controller = TextEditingController(text: widget.viewModel.query);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.viewModel.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.viewModel.search,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por título ou cidade',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: widget.viewModel.query.isEmpty
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
