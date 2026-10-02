import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/utils/formatters.dart';

/// intl separates the currency symbol with a non-breaking space.
const _nbsp = ' ';

Property _property({required String type, required double price}) =>
    Property.fromJson({
      'id': 1,
      'titulo': 'Teste',
      'descricao': '',
      'tipo': type,
      'preco': price,
      'cidade': 'Presidente Prudente',
      'bairro': 'Centro',
      'quartos': 0,
      'banheiros': 0,
      'vagas': 0,
      'area_m2': 1,
      'foto': '',
    });

void main() {
  group('formatPrice', () {
    test('aluguel leva "/mês"', () {
      final property = _property(type: 'aluguel', price: 1800);

      expect(formatPrice(property), 'R\$${_nbsp}1.800,00 /mês');
    });

    test('venda não leva "/mês"', () {
      final property = _property(type: 'venda', price: 420000);

      expect(formatPrice(property), 'R\$${_nbsp}420.000,00');
    });
  });

  group('formatArea', () {
    test('área inteira sem casas decimais', () {
      expect(formatArea(150), '150 m²');
    });

    test('área decimal com vírgula', () {
      expect(formatArea(65.5), '65,5 m²');
    });
  });

  group('contagens (zero, um, vários)', () {
    test('quartos', () {
      expect(formatBedrooms(0), 'Sem quartos');
      expect(formatBedrooms(1), '1 quarto');
      expect(formatBedrooms(3), '3 quartos');
    });

    test('banheiros', () {
      expect(formatBathrooms(0), 'Sem banheiros');
      expect(formatBathrooms(1), '1 banheiro');
      expect(formatBathrooms(2), '2 banheiros');
    });

    test('vagas', () {
      expect(formatParkingSpaces(0), 'Sem vagas');
      expect(formatParkingSpaces(1), '1 vaga');
      expect(formatParkingSpaces(2), '2 vagas');
    });
  });
}
