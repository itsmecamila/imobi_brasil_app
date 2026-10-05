import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/ui/load_states.dart';
import 'package:imobi_app/ui/core/ui/success_snack_bar.dart';
import 'package:imobi_app/ui/property_create/view_models/property_create_view_model.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';
import 'package:imobi_app/ui/property_form/widgets/property_form_view.dart';
import 'package:provider/provider.dart';

const _screenTitle = 'Cadastrar imóvel';

class PropertyCreateScreen extends StatelessWidget {
  const PropertyCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyCreateViewModel>();

    return LoadStates(
      title: _screenTitle,
      loadingMessage: 'Carregando…',
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.retry,
      builder: (context) => _CreateForm(viewModel: viewModel),
    );
  }
}

class _CreateForm extends StatelessWidget {
  const _CreateForm({required this.viewModel});

  final PropertyCreateViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    void backToList() => context.go(Routes.home);

    // Feedback is given here because the list only awaits the result when
    // it opened this screen (not when "/property/new" is opened directly).
    Future<bool> save(PropertyForm form) async {
      final messenger = ScaffoldMessenger.of(context);
      final created = await viewModel.save(form);
      if (created == null || !context.mounted) return created != null;

      context.pop(created);
      messenger.showSnackBar(successSnackBar('Imóvel cadastrado'));
      return true;
    }

    return PropertyFormView(
      screenTitle: _screenTitle,
      initial: const PropertyForm.blank(),
      isSaving: viewModel.isSaving,
      labels: const PropertyFormLabels(
        save: 'Cadastrar',
        saving: 'Cadastrando…',
        saveError: 'Não foi possível cadastrar agora.',
        discardTitle: 'Descartar cadastro?',
        discardMessage:
            'O imóvel não será cadastrado e os dados preenchidos serão '
            'perdidos.',
        keepGoing: 'Continuar cadastrando',
      ),
      hasChanges: viewModel.hasChanges,
      onSave: save,
      onLeave: backToList,
    );
  }
}
