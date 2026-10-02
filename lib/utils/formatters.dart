import 'package:imobi_app/domain/models/property.dart';
import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final _decimal = NumberFormat.decimalPattern('pt_BR');

/// "R$ 1.800,00 /mês" for rent, "R$ 420.000,00" for sale.
String formatPrice(Property property) {
  final price = _currency.format(property.price);
  return property.type == PropertyType.rent ? '$price /mês' : price;
}

/// "150 m²", "65,5 m²".
String formatArea(double area) => '${formatDecimal(area)} m²';

/// "150", "65,5": no unnecessary decimals, comma as separator.
String formatDecimal(double value) => _decimal.format(value);

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
