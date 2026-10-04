import 'package:flutter/foundation.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';

class PropertyEditViewModel extends ChangeNotifier {
  PropertyEditViewModel(this._repository, this.propertyId) {
    _repository.addListener(notifyListeners);
  }

  final PropertyRepository _repository;
  final int propertyId;
  bool _isSaving = false;

  bool get isSaving => _isSaving;
  bool get isLoading => !_repository.hasLoaded && !_repository.loadFailed;
  Property? get original => _repository.findById(propertyId);

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

  /// The draft as a listing, keeping the original id and photo.
  Property toProperty(PropertyForm form) {
    final original = this.original;
    if (original == null) {
      throw StateError('Listing $propertyId is not available');
    }
    return form.toProperty(id: original.id, photoUrl: original.photoUrl);
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
