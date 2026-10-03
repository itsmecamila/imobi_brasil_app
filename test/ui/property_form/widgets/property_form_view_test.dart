import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';
import 'package:imobi_app/ui/property_form/widgets/property_form_view.dart';

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
}
