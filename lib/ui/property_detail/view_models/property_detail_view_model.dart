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

  bool get isLoading => !_repository.hasLoaded;

  Property? get property => _repository.findById(propertyId);

  bool get isNotFound => _repository.hasLoaded && property == null;

  Future<bool> openWhatsApp() async {
    final title = property?.title ?? '';
    return _launcher(
      Uri.https('wa.me', '/${BrokerContact.phoneDigits}', {
        'text': 'Olá! Tenho interesse no imóvel "$title".',
      }),
    );
  }

  Future<bool> call() =>
      _launcher(Uri(scheme: 'tel', path: '+${BrokerContact.phoneDigits}'));

  Future<bool> sendEmail() {
    final title = property?.title ?? '';
    return _launcher(
      Uri(
        scheme: 'mailto',
        path: BrokerContact.email,
        query: 'subject=${Uri.encodeComponent('Interesse: $title')}',
      ),
    );
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }
}
