import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/utils/currency_input.dart';

/// intl separates the currency symbol with a non-breaking space.
const _nbsp = ' ';

final _formatter = CurrencyInputFormatter();

/// Applies [typed] to the field the way the keyboard would.
String _type(String current, String typed) => _formatter
    .formatEditUpdate(
      TextEditingValue(text: current),
      TextEditingValue(text: typed),
    )
    .text;

void main() {
  group('CurrencyInputFormatter', () {
    test('dígitos entram pela direita, como centavos', () {
      var text = _type('', '4');
      expect(text, 'R\$${_nbsp}0,04');
      text = _type(text, '${text}2');
      expect(text, 'R\$${_nbsp}0,42');
      text = _type(text, '${text}0');
      expect(text, 'R\$${_nbsp}4,20');
    });

    test('apagar remove o último dígito', () {
      final text = 'R\$${_nbsp}4,20';

      expect(
        _type(text, text.substring(0, text.length - 1)),
        'R\$${_nbsp}0,42',
      );
    });

    test('apagar o último dígito deixa o campo vazio', () {
      expect(_type('R\$${_nbsp}0,04', 'R\$${_nbsp}0,0'), '');
    });

    test('letras e símbolos são ignorados', () {
      expect(_type('', 'a1b8c0d0e0f0'), 'R\$${_nbsp}1.800,00');
    });

    test('limite de 12 dígitos mantém o valor anterior', () {
      final full = _type('', '999999999999');

      expect(_type(full, '${full}9'), full);
    });
  });

  group('parseCents', () {
    test('lê os centavos de um texto com máscara', () {
      expect(parseCents('R\$${_nbsp}1.800,00'), 180000);
    });

    test('texto vazio vale zero', () {
      expect(parseCents(''), 0);
    });
  });
}
