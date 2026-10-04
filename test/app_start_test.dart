import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/auth_service.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/main.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Moves the fake clock and lets real async work (asset, storage) finish.
Future<void> _settleWithRealAsync(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
}

void main() {
  // The same start as main(): session restored and listings loading before
  // the first frame, then splash → login → list. A load notifying in the
  // middle of a build once left the list stuck on the skeleton.
  testWidgets('abrir o app, entrar e ver a lista', (tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final storage = SharedPreferencesAsync();
    final auth = AuthRepository(
      AuthService(storage: storage, simulateError: false),
    );
    await tester.runAsync(auth.restoreSession);
    final properties = PropertyRepository(
      PropertyService(storage: storage, simulateError: false),
    );
    properties.load().ignore();

    await tester.pumpWidget(
      appWithProviders(auth: auth, properties: properties),
    );
    await _settleWithRealAsync(tester);

    await tester.enterText(
      find.byType(TextField).at(0),
      'corretor@imobibrasil.com.br',
    );
    await tester.enterText(find.byType(TextField).at(1), 'imobi2026');
    await tester.tap(find.text('Entrar'));
    await _settleWithRealAsync(tester);

    expect(find.byType(PropertyListSkeleton), findsNothing);
    expect(find.byType(PropertyCard), findsWidgets);
  });
}
