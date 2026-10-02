import 'package:go_router/go_router.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_screen.dart';

abstract final class Routes {
  static const home = '/';
  static String property(int id) => '/property/$id';
  static String editProperty(int id) => '/property/$id/edit';
}

GoRouter createRouter() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const PropertyListScreen(),
    ),
  ],
);
