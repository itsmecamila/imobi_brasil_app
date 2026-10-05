import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/ui/load_states.dart';
import 'package:imobi_app/ui/core/ui/success_snack_bar.dart';
import 'package:imobi_app/ui/property_edit/view_models/property_edit_view_model.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';
import 'package:imobi_app/ui/property_form/widgets/property_form_view.dart';
import 'package:provider/provider.dart';

const _screenTitle = 'Editar imóvel';

class PropertyEditScreen extends StatelessWidget {
  const PropertyEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyEditViewModel>();
    final original = viewModel.original;

    return LoadStates(
      title: _screenTitle,
      loadingMessage: 'Carregando imóvel…',
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.retry,
      builder: (context) => original == null
          ? const ListingNotFound(title: _screenTitle)
          : _EditForm(viewModel: viewModel, original: original),
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({required this.viewModel, required this.original});

  final PropertyEditViewModel viewModel;
  final Property original;

  @override
  Widget build(BuildContext context) {
    void backToDetail() => context.go(Routes.property(original.id));

    Future<bool> save(PropertyForm form) async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await viewModel.save(form);
      if (!saved || !context.mounted) return saved;

      backToDetail();
      messenger.showSnackBar(successSnackBar('Imóvel atualizado'));
      return true;
    }

    return PropertyFormView(
      screenTitle: _screenTitle,
      initial: PropertyForm.fromProperty(original),
      isSaving: viewModel.isSaving,
      labels: const PropertyFormLabels(
        save: 'Salvar',
        saving: 'Salvando…',
        saveError: 'Não foi possível salvar agora.',
        discardTitle: 'Descartar alterações?',
        discardMessage:
            'As mudanças não serão salvas e o imóvel continua como estava.',
        keepGoing: 'Continuar editando',
      ),
      hasChanges: viewModel.hasChanges,
      onSave: save,
      onLeave: backToDetail,
    );
  }
}
