import 'package:go_router/go_router.dart';
import 'package:gym_app/features/perfil/presentation/pages/perfil_page.dart';

final perfilRoutes = <GoRoute>[
  GoRoute(
    path: '/perfil',
    builder: (context, state) {
      return PerfilPage();
    },
  ),
];
