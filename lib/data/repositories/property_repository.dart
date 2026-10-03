import 'package:flutter/foundation.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/domain/models/property.dart';

/// Source of truth for listings: keeps them in memory and notifies
/// listeners whenever they change.
class PropertyRepository extends ChangeNotifier {
  PropertyRepository(this._service);

  final PropertyService _service;
  List<Property> _properties = [];
  bool _hasLoaded = false;

  List<Property> get properties => List.unmodifiable(_properties);

  /// Distinguishes "still loading" from "loaded, but the listing is missing".
  bool get hasLoaded => _hasLoaded;

  Property? findById(int id) {
    for (final property in _properties) {
      if (property.id == id) return property;
    }
    return null;
  }

  Future<void> load() async {
    final raw = await _service.fetchProperties();
    _properties = raw.map(Property.fromJson).toList();
    _hasLoaded = true;
    notifyListeners();
  }

  /// Saves first and only then changes the list (pessimistic update):
  /// if saving fails, the list keeps the previous data.
  Future<void> update(Property edited) async {
    await _service.saveProperty(edited.toJson());
    _properties = _properties
        .map((property) => property.id == edited.id ? edited : property)
        .toList();
    notifyListeners();
  }

  /// Incremental id for a new listing: the highest id plus one.
  int get nextId =>
      _properties.fold(0, (highest, p) => p.id > highest ? p.id : highest) + 1;

  /// Same pessimistic order as [update]. The new listing goes on top
  /// (newest first), so it is visible right after saving.
  Future<void> add(Property created) async {
    await _service.createProperty(created.toJson());
    _properties = [created, ..._properties];
    notifyListeners();
  }
}
