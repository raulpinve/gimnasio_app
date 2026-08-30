import 'package:gym_app/features/routines/presentation/pages/routine_list_page.dart';
import 'package:go_router/go_router.dart';

final routineRoutes = <GoRoute>[
  // ABRIR EL LISTADO DE LA RUTINA
  GoRoute(
    path: '/routines',
    builder: (context, state) {
      return RoutineListPage();
    },
  ),
];
