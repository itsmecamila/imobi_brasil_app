import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/ui/splash/widgets/splash_gate.dart';

void main() {
  testWidgets('mostra o logo por 2 s e depois o app', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashGate(child: Text('app'))),
    );

    expect(find.bySemanticsLabel('ImobiBrasil'), findsOneWidget);

    // Fast-forwards the fake clock: no real 2-second wait.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('ImobiBrasil'), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });
}
