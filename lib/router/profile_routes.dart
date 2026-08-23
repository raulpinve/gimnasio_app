import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/profile/data/api_profile_repo.dart';
import 'package:gym_app/features/profile/presentation/cubits/profile/profile_update_cubit.dart';
import 'package:gym_app/features/profile/presentation/pages/profile_update_page.dart';

final profileRoutes = <GoRoute>[
  GoRoute(
    path: '/profile/update',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => ProfileUpdateCubit(
          profileRepo: ApiProfileRepo(),
        ),
        child: const ProfileUpdatePage(),
      );
    },
  ),
];
