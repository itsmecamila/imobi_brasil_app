import 'package:flutter/material.dart';
import 'package:imobi_app/config/broker.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/property_detail/view_models/property_detail_view_model.dart';

/// Same content in two wrappers: bottom sheet on compact screens (< 600),
/// dialog on wide ones.
Future<void> showContactOptions(
  BuildContext context,
  PropertyDetailViewModel viewModel,
) {
  final content = _ContactOptions(viewModel: viewModel);
  if (MediaQuery.sizeOf(context).width < 600) {
    return showModalBottomSheet<void>(
      context: context,
      // Sized by its content instead of the default ~56% height cap.
      isScrollControlled: true,
      builder: (_) => SafeArea(child: SingleChildScrollView(child: content)),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(child: content),
      ),
    ),
  );
}

class _ContactOptions extends StatelessWidget {
  const _ContactOptions({required this.viewModel});

  final PropertyDetailViewModel viewModel;

  Future<void> _open(
    BuildContext context,
    Future<bool> Function() action,
    String failureMessage,
  ) async {
    // Captured before closing: the sheet's context goes away with it.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (!await action()) {
      messenger.showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fale com o corretor', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const _Leading(
              CircleAvatar(
                backgroundColor: AppColors.brand50,
                foregroundColor: AppColors.brand700,
                child: Icon(Icons.person_outline),
              ),
            ),
            title: Text(BrokerContact.name, style: textTheme.titleSmall),
            subtitle: Text(
              'Dados de exemplo',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ),
          _ContactTile(
            icon: Icons.chat_outlined,
            label: 'WhatsApp',
            value: BrokerContact.phoneDisplay,
            onTap: () => _open(
              context,
              viewModel.openWhatsApp,
              'Não foi possível abrir o WhatsApp. '
              'Tente ligar ou enviar um e-mail.',
            ),
          ),
          _ContactTile(
            icon: Icons.call_outlined,
            label: 'Ligar',
            value: BrokerContact.phoneDisplay,
            onTap: () => _open(
              context,
              viewModel.call,
              'Não foi possível abrir o discador. '
              'Tente o WhatsApp ou o e-mail.',
            ),
          ),
          _ContactTile(
            icon: Icons.mail_outline,
            label: 'E-mail',
            value: BrokerContact.email,
            onTap: () => _open(
              context,
              viewModel.sendEmail,
              'Não foi possível abrir o e-mail. '
              'Tente o WhatsApp ou ligar.',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Leading(Icon(icon, color: AppColors.brand600)),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      onTap: onTap,
    );
  }
}

/// Same 40-wide slot for the avatar and the icons, so icon centers and
/// texts line up across all rows.
class _Leading extends StatelessWidget {
  const _Leading(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 40, height: 40, child: Center(child: child));
  }
}
