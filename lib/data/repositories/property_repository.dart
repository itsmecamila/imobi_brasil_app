import 'dart:collection';

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
  bool _isLoading = false;
  bool _loadFailed = false;
  Future<void>? _ongoingLoad;

  /// A read-only view of the list, without copying it on every read.
  List<Property> get properties => UnmodifiableListView(_properties);

  /// Distinguishes "still loading" from "loaded, but the listing is missing".
  bool get hasLoaded => _hasLoaded;
  bool get isLoading => _isLoading;

  /// Loading failed and there is nothing to show. Kept here, in the source of
  /// truth, so every screen (list, detail, edit, create, photo) shows the
  /// same error, and a retry from any of them fixes all.
  bool get loadFailed => _loadFailed;

  Property? findById(int id) {
    for (final property in _properties) {
      if (property.id == id) return property;
    }
    return null;
  }

  /// Calls made while a load is running share it, so two screens (or
  /// "Restaurar" during the first load) never race each other.
  Future<void> load() =>
      _ongoingLoad ??= _load().whenComplete(() => _ongoingLoad = null);

  Future<void> _load() async {
    _isLoading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      final raw = await _service.fetchProperties();
      _properties = raw.map(Property.fromJson).toList();
      _hasLoaded = true;
    } catch (_) {
      _loadFailed = !_hasLoaded;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  /// Throws away every edit and new listing and shows the sample data.
  /// On failure nothing changes, here or on the device.
  Future<void> resetToSample() async {
    final raw = await _service.resetToSample();
    _properties = raw.map(Property.fromJson).toList();
    _hasLoaded = true;
    _loadFailed = false;
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
