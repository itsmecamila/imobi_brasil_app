import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/services/auth_service.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/login/view_models/login_view_model.dart';
import 'package:imobi_app/ui/login/widgets/login_screen.dart';
import 'package:provider/provider.dart';

Future<AuthRepository> _pumpLogin(WidgetTester tester) async {
  final repository = AuthRepository(
    AuthService(delay: Duration.zero, simulateError: false),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => LoginViewModel(repository),
      child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    ),
  );
  return repository;
}

Finder get _emailField => find.byType(TextField).at(0);
Finder get _passwordField => find.byType(TextField).at(1);

void main() {
  testWidgets('entrar em branco aponta os dois campos e não envia', (
    tester,
  ) async {
    final repository = await _pumpLogin(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);
    expect(repository.isSignedIn, isFalse);
  });

  testWidgets('senha errada mostra a mensagem genérica, que some ao digitar', (
    tester,
  ) async {
    await _pumpLogin(tester);
    await tester.enterText(_emailField, 'corretor@imobibrasil.com.br');
    await tester.enterText(_passwordField, 'errada');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);

    await tester.enterText(_passwordField, 'errada2');
    await tester.pump();
    expect(find.text('E-mail ou senha incorretos.'), findsNothing);
  });

  testWidgets('credenciais certas pelo "Entrar" do teclado', (tester) async {
    final repository = await _pumpLogin(tester);
    await tester.enterText(_emailField, 'corretor@imobibrasil.com.br');
    await tester.enterText(_passwordField, 'imobi2026');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.isSignedIn, isTrue);
  });

  testWidgets('👁 mostra e oculta a senha e é um botão para leitores de tela', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpLogin(tester);
    bool obscured() => tester.widget<TextField>(_passwordField).obscureText;

    expect(obscured(), isTrue);
    // Its own button, not merged into the field.
    expect(
      tester.getSemantics(find.byTooltip('Mostrar senha')),
      isSemantics(isButton: true, hasTapAction: true, isTextField: false),
    );

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();

    expect(obscured(), isFalse);
    expect(find.byTooltip('Ocultar senha'), findsOneWidget);
    semantics.dispose();
  });
}
