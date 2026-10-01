import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/domain/models/property.dart';

void main() {
  // One listing in the API format (Portuguese keys).
  final json = <String, dynamic>{
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
    'foto': 'https://picsum.photos/seed/apt1/600/400',
  };

  group('Property.fromJson', () {
    test('traduz as chaves em português para os campos em inglês', () {
      final property = Property.fromJson(json);

      expect(property.id, 1);
      expect(property.title, 'Apartamento Centro');
      expect(property.description, 'Perto do comércio.');
      expect(property.type, PropertyType.rent);
      expect(property.price, 1800.0);
      expect(property.city, 'Presidente Prudente');
      expect(property.neighborhood, 'Centro');
      expect(property.bedrooms, 2);
      expect(property.bathrooms, 1);
      expect(property.parkingSpaces, 1);
      expect(property.photoUrl, 'https://picsum.photos/seed/apt1/600/400');
    });

    test('converte área inteira (65) em decimal (65.0)', () {
      final property = Property.fromJson(json);

      expect(property.area, 65.0);
    });

    test('lança erro quando o tipo é desconhecido', () {
      final invalid = {...json, 'tipo': 'permuta'};

      expect(() => Property.fromJson(invalid), throwsFormatException);
    });
  });
}
