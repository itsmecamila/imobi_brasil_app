import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';

final _property = Property.fromJson({
  'id': 1,
  'titulo': 'Apartamento Centro',
  'descricao': 'Perto do comércio.',
  'tipo': 'aluguel',
  'preco': 1800.00,
  'cidade': 'Presidente Prudente',
  'bairro': 'Centro',
  'quartos': 2,
  'banheiros': 1,
  'vagas': 1,
  'area_m2': 65,
  'foto': 'https://example.com/foto.jpg',
});

void main() {
  testWidgets('mostra os dados formatados e responde ao toque', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PropertyCard(property: _property, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Apartamento Centro'), findsOneWidget);
    expect(find.text('Presidente Prudente'), findsOneWidget);
    expect(find.text('ALUGUEL'), findsOneWidget);
    expect(find.textContaining('/mês'), findsOneWidget);

    await tester.tap(find.byType(PropertyCard));
    expect(tapped, isTrue);
  });

  testWidgets('mostra "Foto indisponível" quando a foto falha', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PropertyCard(property: _property, onTap: () {}),
        ),
      ),
    );
    // Tests have no internet: the image request fails on purpose.
    await tester.pumpAndSettle();

    expect(find.text('Foto indisponível'), findsOneWidget);
  });
}
