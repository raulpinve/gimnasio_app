import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_create/routine_create_cubit.dart';
import 'package:gym_app/features/routines/presentation/pages/routine_create_page.dart';
import 'package:gym_app/features/routines/presentation/pages/routine_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final routineRoutes = <GoRoute>[
  // ABRIR EL LISTADO DE LA RUTINA
  GoRoute(
    path: '/routines',
    builder: (context, state) {
      return RoutineListPage();
    },
  ),

  // Crear una nueva rutina
  GoRoute(
    path: '/routines/create',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => RoutineCreateCubit(routineRepo: ApiRoutineRepo()),
        child: RoutineCreatePage(),
      );
    },
  ),
];
