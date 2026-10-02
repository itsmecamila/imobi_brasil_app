import 'package:flutter/foundation.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/utils/currency_input.dart';
import 'package:imobi_app/utils/formatters.dart';

/// The edit draft: field values as text, exactly as they are on screen.
/// The shared list only changes when the draft is saved.
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
  final PropertyType type;
  final String price;
  final String city;
  final String neighborhood;
  final String bedrooms;
  final String bathrooms;
  final String parkingSpaces;
  final String area;
}

class PropertyEditViewModel extends ChangeNotifier {
  PropertyEditViewModel(this._repository, this.propertyId) {
    _repository.addListener(notifyListeners);
  }

  final PropertyRepository _repository;
  final int propertyId;
  bool _isSaving = false;

  bool get isSaving => _isSaving;
  bool get isLoading => !_repository.hasLoaded;
  Property? get original => _repository.findById(propertyId);
  bool get isNotFound => _repository.hasLoaded && original == null;

  static String? validateTitle(String? value) =>
      _required(value, 'Informe o título.');

  static String? validateCity(String? value) =>
      _required(value, 'Informe a cidade.');

  static String? validateNeighborhood(String? value) =>
      _required(value, 'Informe o bairro.');

  static String? validatePrice(String? value) =>
      parseCents(value ?? '') > 0 ? null : 'Informe um preço maior que zero.';

  static String? validateArea(String? value) => (_parseDecimal(value) ?? 0) > 0
      ? null
      : 'Informe uma área maior que zero.';

  /// Turns the draft texts into a listing: "R$ 420.000,00" → 420000.0,
  /// "65,5" → 65.5, empty counts → 0.
  Property toProperty(PropertyForm form) {
    final original = this.original;
    if (original == null) {
      throw StateError('Listing $propertyId is not available');
    }
    return Property(
      id: original.id,
      title: form.title.trim(),
      description: form.description.trim(),
      type: form.type,
      price: parseCents(form.price) / 100,
      city: form.city.trim(),
      neighborhood: form.neighborhood.trim(),
      bedrooms: _parseCount(form.bedrooms),
      bathrooms: _parseCount(form.bathrooms),
      parkingSpaces: _parseCount(form.parkingSpaces),
      area: _parseDecimal(form.area) ?? 0,
      photoUrl: original.photoUrl,
    );
  }

  /// Decides whether leaving needs the "Descartar alterações?" confirmation.
  bool hasChanges(PropertyForm form) =>
      !mapEquals(toProperty(form).toJson(), original?.toJson());

  /// Returns whether it saved; on failure the listing keeps its old data.
  Future<bool> save(PropertyForm form) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.update(toProperty(form));
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}

String? _required(String? value, String message) =>
    (value == null || value.trim().isEmpty) ? message : null;

int _parseCount(String value) => int.tryParse(value.trim()) ?? 0;

double? _parseDecimal(String? value) =>
    double.tryParse((value ?? '').trim().replaceAll(',', '.'));
