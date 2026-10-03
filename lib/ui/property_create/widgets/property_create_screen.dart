import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';
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

    if (viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text(_screenTitle)),
        body: const StateMessage.loading(message: 'Carregando…'),
      );
    }

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
        discardMessage: 'Os dados preenchidos ainda não foram salvos.',
      ),
      hasChanges: viewModel.hasChanges,
      onSave: save,
      onLeave: backToList,
    );
  }
}
