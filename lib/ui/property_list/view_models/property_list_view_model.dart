import 'package:flutter/foundation.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/domain/models/property.dart';

enum PropertyFilter { all, sale, rent }

class PropertyListViewModel extends ChangeNotifier {
  PropertyListViewModel(this._repository) {
    _repository.addListener(notifyListeners);
  }

  final PropertyRepository _repository;

  bool _isLoading = false;
  bool _hasError = false;
  String _query = '';
  PropertyFilter _filter = PropertyFilter.all;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get query => _query;
  PropertyFilter get filter => _filter;

  /// True when there are no listings at all, as opposed to listings hidden
  /// by the search or the filter.
  bool get hasNoProperties => _repository.properties.isEmpty;

  /// Listings that match both the filter and the search (title or city).
  List<Property> get visibleProperties {
    final query = _normalize(_query);
    return _repository.properties
        .where(_matchesFilter)
        .where(
          (property) =>
              query.isEmpty ||
              _normalize(property.title).contains(query) ||
              _normalize(property.city).contains(query),
        )
        .toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      await _repository.load();
    } catch (_) {
      // Any failure gets the same friendly message; details are not shown.
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String text) {
    _query = text;
    notifyListeners();
  }

  void clearSearch() => search('');

  void selectFilter(PropertyFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  bool _matchesFilter(Property property) => switch (_filter) {
    PropertyFilter.all => true,
    PropertyFilter.sale => property.type == PropertyType.sale,
    PropertyFilter.rent => property.type == PropertyType.rent,
  };

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}

const _accents = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'é': 'e',
  'ê': 'e',
  'í': 'i',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ü': 'u',
  'ç': 'c',
};

/// Lowercase, trimmed and without accents, so "Universitária" matches
/// "UNIVERSITARIA".
String _normalize(String text) => text
    .trim()
    .toLowerCase()
    .split('')
    .map((char) => _accents[char] ?? char)
    .join();
