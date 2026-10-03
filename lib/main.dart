import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/auth_service.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/splash/widgets/splash_gate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await precacheSplashLogo();
  // One storage for listings and session: the device's (browser's on web).
  final storage = SharedPreferencesAsync();
  // Created here because the router (outside the widget tree) listens to it.
  final auth = AuthRepository(AuthService(storage: storage));
  await auth.restoreSession();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(
          create: (_) => PropertyRepository(PropertyService(storage: storage)),
        ),
        // Lives above the screens so search, filter and list survive
        // navigation. Not lazy: loading starts as soon as the app opens,
        // even when it opens straight on a detail link (web).
        ChangeNotifierProvider(
          lazy: false,
          create: (context) =>
              PropertyListViewModel(context.read<PropertyRepository>())..load(),
        ),
      ],
      child: ImobiApp(router: createRouter(auth)),
    ),
  );
}

class ImobiApp extends StatelessWidget {
  const ImobiApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ImobiBrasil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) =>
          SplashGate(child: child ?? const SizedBox.shrink()),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
