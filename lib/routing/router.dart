import 'package:go_router/go_router.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/ui/property_detail/view_models/property_detail_view_model.dart';
import 'package:imobi_app/ui/property_detail/widgets/property_detail_screen.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_screen.dart';
import 'package:provider/provider.dart';

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
      // Child route: the list stays underneath, so going back keeps
      // its search, filter and scroll position.
      routes: [
        GoRoute(
          path: 'property/:id',
          builder: (context, state) {
            // An invalid id (e.g. "/property/abc") becomes "not found".
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return ChangeNotifierProvider(
              create: (context) => PropertyDetailViewModel(
                context.read<PropertyRepository>(),
                id ?? -1,
              ),
              child: const PropertyDetailScreen(),
            );
          },
        ),
      ],
    ),
  ],
);
