import 'package:flutter/foundation.dart';
import 'package:imobi_app/config/broker.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a link in another app; returns false when it cannot.
typedef LinkLauncher = Future<bool> Function(Uri uri);

Future<bool> _launchExternally(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

class PropertyDetailViewModel extends ChangeNotifier {
  PropertyDetailViewModel(
    this._repository,
    this.propertyId, {
    this._launcher = _launchExternally,
  }) {
    _repository.addListener(notifyListeners);
  }

  final PropertyRepository _repository;
  final LinkLauncher _launcher;
  final int propertyId;

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

  Property? get property => _repository.findById(propertyId);

  Future<bool> openWhatsApp() async {
    final title = property?.title ?? '';
    return _open(
      Uri.https('wa.me', '/${BrokerContact.phoneDigits}', {
        'text': 'Olá! Tenho interesse no imóvel "$title".',
      }),
    );
  }

  Future<bool> call() =>
      _open(Uri(scheme: 'tel', path: '+${BrokerContact.phoneDigits}'));

  Future<bool> sendEmail() {
    final title = property?.title ?? '';
    return _open(
      Uri(
        scheme: 'mailto',
        path: BrokerContact.email,
        query: 'subject=${Uri.encodeComponent('Interesse: $title')}',
      ),
    );
  }

  /// Some devices throw instead of returning false (no app for the link, or
  /// a platform error); both mean "could not open", which the screen reports.
  Future<bool> _open(Uri uri) async {
    try {
      return await _launcher(uri);
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
