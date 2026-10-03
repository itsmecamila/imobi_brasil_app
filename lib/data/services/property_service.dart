import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulated API for listings: the JSON asset is the sample data, and the
/// device storage plays the server's database, so changes survive closing
/// the app.
///
/// Returns and receives raw API data (Portuguese keys); translating it into
/// models is the repository's job.
class PropertyService {
  PropertyService({
    this.storage,
    this.simulateError = const bool.fromEnvironment('SIMULATE_ERROR'),
    this.loadDelay = const Duration(milliseconds: 1500),
    this.saveDelay = const Duration(seconds: 1),
  });

  /// Where changes are kept. Without it (tests), nothing is kept between
  /// runs and the asset is always the starting point.
  final SharedPreferencesAsync? storage;

  /// When true, every call fails, to exercise the error states.
  /// Enabled with `flutter run --dart-define=SIMULATE_ERROR=true`.
  final bool simulateError;
  final Duration loadDelay;
  final Duration saveDelay;

  static const _storageKey = 'imoveis';

  Future<List<Map<String, dynamic>>> fetchProperties() async {
    await Future<void>.delayed(loadDelay);
    if (simulateError) throw Exception('Simulated network error');
    return _current();
  }

  Future<void> saveProperty(Map<String, dynamic> json) async {
    await _simulateRequest();
    await _write(
      (all) => all.map((p) => p['id'] == json['id'] ? json : p).toList(),
    );
  }

  /// A real API would usually create and update through different calls, so
  /// the contract is kept separate. New listings go on top (newest first).
  Future<void> createProperty(Map<String, dynamic> json) async {
    await _simulateRequest();
    await _write((all) => [json, ...all]);
  }

  /// Forgets every change: the next fetch returns the sample data again.
  Future<void> resetToSample() async {
    await _simulateRequest();
    await storage?.remove(_storageKey);
  }

  Future<void> _simulateRequest() async {
    await Future<void>.delayed(saveDelay);
    if (simulateError) throw Exception('Simulated network error');
  }

  /// The saved listings, or the sample data if nothing was saved yet.
  Future<List<Map<String, dynamic>>> _current() async {
    final saved = await storage?.getString(_storageKey);
    if (saved != null) return _decodeList(saved);

    final raw = await rootBundle.loadString('assets/properties.json');
    final body = jsonDecode(raw) as Map<String, dynamic>;
    return (body['imoveis'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> _write(
    List<Map<String, dynamic>> Function(List<Map<String, dynamic>> all) change,
  ) async {
    final storage = this.storage;
    if (storage == null) return;
    final updated = change(await _current());
    await storage.setString(_storageKey, jsonEncode(updated));
  }

  static List<Map<String, dynamic>> _decodeList(String raw) =>
      (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
}
