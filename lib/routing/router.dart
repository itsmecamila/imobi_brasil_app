import 'package:go_router/go_router.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/ui/property_create/view_models/property_create_view_model.dart';
import 'package:imobi_app/ui/property_create/widgets/property_create_screen.dart';
import 'package:imobi_app/ui/property_detail/view_models/property_detail_view_model.dart';
import 'package:imobi_app/ui/property_detail/widgets/property_detail_screen.dart';
import 'package:imobi_app/ui/property_edit/view_models/property_edit_view_model.dart';
import 'package:imobi_app/ui/property_edit/widgets/property_edit_screen.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_screen.dart';
import 'package:imobi_app/ui/property_photo/widgets/property_photo_screen.dart';
import 'package:provider/provider.dart';

abstract final class Routes {
  static const home = '/';
  static const newProperty = '/property/new';
  static String property(int id) => '/property/$id';
  static String editProperty(int id) => '/property/$id/edit';
  static String propertyPhoto(int id) => '/property/$id/photo';
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
        // Before 'property/:id', which would otherwise read "new" as an id.
        GoRoute(
          path: 'property/new',
          builder: (context, state) => ChangeNotifierProvider(
            create: (context) =>
                PropertyCreateViewModel(context.read<PropertyRepository>()),
            child: const PropertyCreateScreen(),
          ),
        ),
        GoRoute(
          path: 'property/:id',
          builder: (context, state) => ChangeNotifierProvider(
            create: (context) => PropertyDetailViewModel(
              context.read<PropertyRepository>(),
              _idFrom(state),
            ),
            child: const PropertyDetailScreen(),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => PropertyEditViewModel(
                  context.read<PropertyRepository>(),
                  _idFrom(state),
                ),
                child: const PropertyEditScreen(),
              ),
            ),
            GoRoute(
              path: 'photo',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => PropertyDetailViewModel(
                  context.read<PropertyRepository>(),
                  _idFrom(state),
                ),
                child: const PropertyPhotoScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// An invalid id (e.g. "/property/abc") becomes -1, shown as "not found".
int _idFrom(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
