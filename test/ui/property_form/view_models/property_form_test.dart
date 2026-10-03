import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';

void main() {
  group('PropertyFormRules', () {
    test('obrigatórios vazios (ou só espaços) mostram a mensagem', () {
      expect(PropertyFormRules.validateTitle('  '), 'Informe o título.');
      expect(PropertyFormRules.validateCity(''), 'Informe a cidade.');
      expect(PropertyFormRules.validateNeighborhood(null), 'Informe o bairro.');
      expect(PropertyFormRules.validateTitle('Casa'), isNull);
    });

    test('tipo precisa ser escolhido', () {
      expect(PropertyFormRules.validateType(null), 'Escolha venda ou aluguel.');
      expect(PropertyFormRules.validateType(PropertyType.rent), isNull);
    });

    test('preço precisa ser maior que zero', () {
      const message = 'Informe um preço maior que zero.';
      expect(PropertyFormRules.validatePrice(''), message);
      expect(PropertyFormRules.validatePrice('R\$ 0,00'), message);
      expect(PropertyFormRules.validatePrice('R\$ 0,01'), isNull);
    });

    test('área precisa ser maior que zero e aceita vírgula', () {
      const message = 'Informe uma área maior que zero.';
      expect(PropertyFormRules.validateArea(''), message);
      expect(PropertyFormRules.validateArea('0'), message);
      expect(PropertyFormRules.validateArea('65,5'), isNull);
    });
  });

  group('PropertyForm', () {
    test('em branco: nada digitado nem escolhido', () {
      expect(const PropertyForm.blank().isBlank, isTrue);
      expect(
        const PropertyForm(
          title: '',
          description: '',
          type: PropertyType.rent,
          price: '',
          city: '',
          neighborhood: '',
          bedrooms: '',
          bathrooms: '',
          parkingSpaces: '',
          area: '',
        ).isBlank,
        isFalse,
      );
    });

    test('não vira imóvel sem o tipo escolhido', () {
      expect(
        () => const PropertyForm.blank().toProperty(id: 7, photoUrl: ''),
        throwsStateError,
      );
    });
  });
}
