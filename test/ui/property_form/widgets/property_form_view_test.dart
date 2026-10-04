import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';
import 'package:imobi_app/ui/property_form/widgets/property_form_view.dart';
import 'package:imobi_app/utils/currency_input.dart';

import '../../../helpers/fonts.dart';

const _labels = PropertyFormLabels(
  save: 'Cadastrar',
  saving: 'Cadastrando…',
  saveError: 'Não foi possível cadastrar agora.',
  discardMessage: 'Os dados preenchidos ainda não foram salvos.',
);

Widget _app({
  required PropertyForm initial,
  required Future<bool> Function(PropertyForm) onSave,
}) => MaterialApp(
  home: PropertyFormView(
    screenTitle: 'Cadastrar imóvel',
    initial: initial,
    isSaving: false,
    labels: _labels,
    hasChanges: (form) => !form.isBlank,
    onSave: onSave,
    onLeave: () {},
  ),
);

void main() {
  testWidgets('em branco: aponta os 6 obrigatórios, incluindo o tipo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var saveCalls = 0;
    await tester.pumpWidget(
      _app(
        initial: const PropertyForm.blank(),
        onSave: (_) async {
          saveCalls++;
          return true;
        },
      ),
    );
    expect(find.text('Selecione…'), findsOneWidget);
    // Every field shows an example of what to type (tall screen: the list
    // only builds the fields that are visible).
    for (final hint in [
      'Ex.: Casa com quintal no Jardim Bongiovani',
      'Ex.: reformada, perto de escolas e do comércio',
      formatCents(0),
      'Ex.: Presidente Prudente',
      'Ex.: Centro',
      'Ex.: 65,5',
    ]) {
      expect(find.text(hint), findsOneWidget, reason: hint);
    }
    expect(find.text('0'), findsNWidgets(3));

    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('Escolha venda ou aluguel.'), findsOneWidget);
    expect(
      find.text('Corrija os 6 campos destacados para salvar.'),
      findsOneWidget,
    );
    expect(saveCalls, 0);
  });

  testWidgets('erro ao salvar mostra a mensagem com "Atualizar"', (
    tester,
  ) async {
    PropertyForm? sent;
    await tester.pumpWidget(
      _app(
        initial: const PropertyForm(
          title: 'Casa Nova',
          description: '',
          type: PropertyType.rent,
          price: 'R\$ 1.500,00',
          city: 'Presidente Prudente',
          neighborhood: 'Centro',
          bedrooms: '',
          bathrooms: '',
          parkingSpaces: '',
          area: '70',
        ),
        onSave: (form) async {
          sent = form;
          return false;
        },
      ),
    );

    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(sent?.title, 'Casa Nova');
    expect(sent?.type, PropertyType.rent);
    expect(find.text('Não foi possível cadastrar agora.'), findsOneWidget);
    expect(find.text('Atualizar'), findsOneWidget);
  });

  group('barra de botões', () {
    for (final (:saving, :textScale) in [
      (saving: false, textScale: 1.0),
      (saving: true, textScale: 1.0),
      (saving: false, textScale: 1.3),
      (saving: true, textScale: 1.3),
      (saving: true, textScale: 1.5),
    ]) {
      testWidgets('cabe em 360 de largura '
          '(${saving ? 'salvando' : 'parada'}, fonte x$textScale)', (
        tester,
      ) async {
        await loadAppFonts(tester);
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: PropertyFormView(
              screenTitle: 'Cadastrar imóvel',
              initial: const PropertyForm.blank(),
              isSaving: saving,
              labels: _labels,
              hasChanges: (_) => false,
              onSave: (_) async => true,
              onLeave: () {},
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(
          find.text(saving ? 'Cadastrando…' : 'Cadastrar'),
          findsOneWidget,
        );
      });
    }
  });
}
