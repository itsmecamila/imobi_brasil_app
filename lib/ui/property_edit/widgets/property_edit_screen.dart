import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';
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

    if (viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text(_screenTitle)),
        body: const StateMessage.loading(message: 'Carregando imóvel…'),
      );
    }
    if (original == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(_screenTitle)),
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

    void backToDetail() => context.go(Routes.property(original.id));

    Future<bool> save(PropertyForm form) async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await viewModel.save(form);
      if (!saved || !context.mounted) return saved;

      backToDetail();
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.brand50),
              SizedBox(width: 8),
              Text('Imóvel atualizado'),
            ],
          ),
        ),
      );
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
        discardMessage:
            'As mudanças feitas neste imóvel ainda não foram salvas.',
      ),
      hasChanges: viewModel.hasChanges,
      onSave: save,
      onLeave: backToDetail,
    );
  }
}
