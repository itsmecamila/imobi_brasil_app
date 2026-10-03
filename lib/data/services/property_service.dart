import 'dart:convert';

import 'package:flutter/services.dart';

/// Simulated API for listings, backed by the JSON asset.
///
/// Returns and receives raw API data (Portuguese keys); translating it into
/// models is the repository's job.
class PropertyService {
  PropertyService({
    this.simulateError = const bool.fromEnvironment('SIMULATE_ERROR'),
    this.loadDelay = const Duration(milliseconds: 1500),
    this.saveDelay = const Duration(seconds: 1),
  });

  /// When true, every call fails, to exercise the error states.
  /// Enabled with `flutter run --dart-define=SIMULATE_ERROR=true`.
  final bool simulateError;
  final Duration loadDelay;
  final Duration saveDelay;

  Future<List<Map<String, dynamic>>> fetchProperties() async {
    await Future<void>.delayed(loadDelay);
    if (simulateError) throw Exception('Simulated network error');

    final raw = await rootBundle.loadString('assets/properties.json');
    final body = jsonDecode(raw) as Map<String, dynamic>;
    return (body['imoveis'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> saveProperty(Map<String, dynamic> json) async {
    // A real API would send `json`; the mock only simulates latency and failure.
    await Future<void>.delayed(saveDelay);
    if (simulateError) throw Exception('Simulated network error');
  }

  /// Same simulated request as saving; a real API would usually create and
  /// update through different calls, so the contract is kept separate.
  Future<void> createProperty(Map<String, dynamic> json) => saveProperty(json);
}
