import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final _nonDigits = RegExp(r'\D');
final _leadingZeros = RegExp(r'^0+');

/// Cash-register style input: digits fill from the right as cents
/// ("4" → R$ 0,04, "42" → R$ 0,42, "420" → R$ 4,20).
class CurrencyInputFormatter extends TextInputFormatter {
  /// Up to R$ 9.999.999.999,99.
  static const _maxDigits = 12;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Leading zeros are dropped, so deleting down from "R$ 0,04" empties the
    // field instead of getting stuck at "R$ 0,00".
    final digits = newValue.text
        .replaceAll(_nonDigits, '')
        .replaceFirst(_leadingZeros, '');
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > _maxDigits) return oldValue;

    final text = formatCents(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String formatCents(int cents) => _currency.format(cents / 100);

/// Reads the cents back from a masked text; empty or invalid text is 0.
int parseCents(String text) =>
    int.tryParse(text.replaceAll(_nonDigits, '')) ?? 0;
