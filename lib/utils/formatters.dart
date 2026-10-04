import 'package:imobi_app/domain/models/property.dart';
import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final _decimal = NumberFormat.decimalPattern('pt_BR');
final _decimalInput = NumberFormat('0.##', 'pt_BR');

/// "R$ 1.800,00". The only currency format in the app, shared by the screens
/// and the price field's mask.
String formatCurrency(double value) => _currency.format(value);

/// "R$ 1.800,00 /mês" for rent, "R$ 420.000,00" for sale.
String formatPrice(Property property) {
  final price = formatCurrency(property.price);
  return property.type == PropertyType.rent ? '$price /mês' : price;
}

/// "150 m²", "65,5 m²".
String formatArea(double area) => '${formatDecimal(area)} m²';

/// "150", "65,5", "2.000": for reading, with a thousands separator.
String formatDecimal(double value) => _decimal.format(value);

/// "2000", "65,5": for a text field. A thousands dot would be read back as a
/// decimal point when the form is saved ("2.000" → 2 m²).
String formatDecimalInput(double value) => _decimalInput.format(value);

String formatBedrooms(int count) =>
    _count(count, zero: 'Sem quartos', one: 'quarto', many: 'quartos');

String formatBathrooms(int count) =>
    _count(count, zero: 'Sem banheiros', one: 'banheiro', many: 'banheiros');

String formatParkingSpaces(int count) =>
    _count(count, zero: 'Sem vagas', one: 'vaga', many: 'vagas');

String _count(
  int count, {
  required String zero,
  required String one,
  required String many,
}) => switch (count) {
  0 => zero,
  1 => '1 $one',
  _ => '$count $many',
};
