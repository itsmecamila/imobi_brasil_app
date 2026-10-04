import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/state_message.dart';

/// Loading and load-error screens for the pages that need the listings
/// (detail, edit, create, photo), opened straight from a link on the web or
/// while the list is still loading. Once the listings are ready, [builder]
/// draws the page.
class LoadStates extends StatelessWidget {
  const LoadStates({
    super.key,
    required this.title,
    required this.loadingMessage,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.builder,
  });

  final String title;
  final String loadingMessage;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: StateMessage.loading(message: loadingMessage),
      );
    }
    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: StateMessage(
          icon: Icons.cloud_off_outlined,
          iconColor: AppColors.danger,
          message: 'Não foi possível carregar os imóveis agora.',
          hint: 'Verifique a conexão e tente de novo.',
          action: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
          ),
        ),
      );
    }
    return builder(context);
  }
}

/// A link to a listing that no longer exists (or never did).
class ListingNotFound extends StatelessWidget {
  const ListingNotFound({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
}
