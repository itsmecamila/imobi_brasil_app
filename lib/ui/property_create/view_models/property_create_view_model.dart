import 'package:flutter/foundation.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';

/// The app has no photo upload, so a new listing gets a stable placeholder
/// photo from the same service as the mock data.
String placeholderPhotoUrl(int id) =>
    'https://picsum.photos/seed/imovel-$id/600/400';

class PropertyCreateViewModel extends ChangeNotifier {
  PropertyCreateViewModel(this._repository) {
    _repository.addListener(notifyListeners);
  }

  final PropertyRepository _repository;
  bool _isSaving = false;

  bool get isSaving => _isSaving;

  /// The next id depends on the loaded listings, so creating waits for them.
  bool get isLoading => !_repository.hasLoaded && !_repository.loadFailed;

  /// Loading failed (e.g. opened straight from a link while offline).
  bool get hasLoadError => _repository.loadFailed;

  /// "Atualizar": loads again; the repository tells every screen the result.
  Future<void> retry() async {
    try {
      await _repository.load();
    } catch (_) {
      // Shown through [hasLoadError].
    }
  }

  /// Decides whether leaving needs the "Descartar alterações?" confirmation.
  bool hasChanges(PropertyForm form) => !form.isBlank;

  /// Returns the created listing, or null when saving failed (nothing is
  /// added to the list).
  Future<Property?> save(PropertyForm form) async {
    _isSaving = true;
    notifyListeners();
    try {
      final id = _repository.nextId;
      final created = form.toProperty(
        id: id,
        photoUrl: placeholderPhotoUrl(id),
      );
      await _repository.add(created);
      return created;
    } catch (_) {
      return null;
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
