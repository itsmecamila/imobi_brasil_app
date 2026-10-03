import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/utils/currency_input.dart';
import 'package:imobi_app/utils/formatters.dart';

/// The form draft shared by editing and creating: field values as text,
/// exactly as they are on screen. Listings only change when it is saved.
class PropertyForm {
  const PropertyForm({
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.city,
    required this.neighborhood,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpaces,
    required this.area,
  });

  /// A new listing starts with nothing chosen, not even the type.
  const PropertyForm.blank()
    : title = '',
      description = '',
      type = null,
      price = '',
      city = '',
      neighborhood = '',
      bedrooms = '',
      bathrooms = '',
      parkingSpaces = '',
      area = '';

  factory PropertyForm.fromProperty(Property property) => PropertyForm(
    title: property.title,
    description: property.description,
    type: property.type,
    price: formatCents((property.price * 100).round()),
    city: property.city,
    neighborhood: property.neighborhood,
    bedrooms: '${property.bedrooms}',
    bathrooms: '${property.bathrooms}',
    parkingSpaces: '${property.parkingSpaces}',
    area: formatDecimal(property.area),
  );

  final String title;
  final String description;
  final PropertyType? type;
  final String price;
  final String city;
  final String neighborhood;
  final String bedrooms;
  final String bathrooms;
  final String parkingSpaces;
  final String area;

  /// Nothing typed or chosen yet: leaving needs no confirmation.
  bool get isBlank =>
      type == null &&
      [
        title,
        description,
        price,
        city,
        neighborhood,
        bedrooms,
        bathrooms,
        parkingSpaces,
        area,
      ].every((value) => value.trim().isEmpty);

  /// Turns the texts into a listing: "R$ 420.000,00" → 420000.0,
  /// "65,5" → 65.5, empty counts → 0. Only call after validation.
  Property toProperty({required int id, required String photoUrl}) {
    final type = this.type;
    if (type == null) throw StateError('The type must be chosen first');
    return Property(
      id: id,
      title: title.trim(),
      description: description.trim(),
      type: type,
      price: parseCents(price) / 100,
      city: city.trim(),
      neighborhood: neighborhood.trim(),
      bedrooms: _parseCount(bedrooms),
      bathrooms: _parseCount(bathrooms),
      parkingSpaces: _parseCount(parkingSpaces),
      area: _parseDecimal(area) ?? 0,
      photoUrl: photoUrl,
    );
  }
}

/// Business rules of the listing form, with the message shown under each
/// field (null means valid).
abstract final class PropertyFormRules {
  static String? validateTitle(String? value) =>
      _required(value, 'Informe o título.');

  static String? validateCity(String? value) =>
      _required(value, 'Informe a cidade.');

  static String? validateNeighborhood(String? value) =>
      _required(value, 'Informe o bairro.');

  static String? validateType(PropertyType? value) =>
      value == null ? 'Escolha venda ou aluguel.' : null;

  static String? validatePrice(String? value) =>
      parseCents(value ?? '') > 0 ? null : 'Informe um preço maior que zero.';

  static String? validateArea(String? value) => (_parseDecimal(value) ?? 0) > 0
      ? null
      : 'Informe uma área maior que zero.';
}

String? _required(String? value, String message) =>
    (value == null || value.trim().isEmpty) ? message : null;

int _parseCount(String value) => int.tryParse(value.trim()) ?? 0;

double? _parseDecimal(String? value) =>
    double.tryParse((value ?? '').trim().replaceAll(',', '.'));
