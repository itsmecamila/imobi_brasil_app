import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';
import 'package:imobi_app/ui/core/ui/labeled_text_field.dart';
import 'package:imobi_app/ui/login/view_models/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final viewModel = context.read<LoginViewModel>();
    if (viewModel.isSigningIn) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final signedIn = await viewModel.signIn(_email.text, _password.text);
    // Lets the system offer to save the credentials (password managers).
    if (signedIn) TextInput.finishAutofillContext();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final errorMessage = viewModel.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              // Phone width on wide screens (web), so fields do not stretch.
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SvgPicture.asset(
                        'assets/images/imobibrasil-logo.svg',
                        height: 48,
                        semanticsLabel: 'ImobiBrasil',
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Entre para ver os imóveis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      LabeledTextField(
                        label: 'E-mail',
                        hintText: 'nome@exemplo.com.br',
                        isRequired: true,
                        controller: _email,
                        validator: LoginViewModel.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.email,
                          AutofillHints.username,
                        ],
                        onChanged: (_) => viewModel.clearError(),
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Senha',
                        hintText: 'Sua senha',
                        isRequired: true,
                        controller: _password,
                        validator: LoginViewModel.validatePassword,
                        obscureText: !_showPassword,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => viewModel.clearError(),
                        onSubmitted: (_) => _signIn(),
                        suffixIcon: IconButton(
                          tooltip: _showPassword
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: viewModel.isSigningIn ? null : _signIn,
                        child: viewModel.isSigningIn
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Entrando…'),
                                ],
                              )
                            : const Text('Entrar'),
                      ),
                      // Announced by screen readers as soon as it appears.
                      if (errorMessage != null)
                        Semantics(
                          liveRegion: true,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ErrorLine(message: errorMessage),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
