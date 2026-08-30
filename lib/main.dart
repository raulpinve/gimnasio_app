import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/features/auth/data/api_user_repo.dart';
import 'package:gym_app/features/auth/data/firebase_auth_repo.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:gym_app/themes/dark_mode.dart';
import 'package:gym_app/themes/light_mode.dart';
import 'firebase_options.dart';
import 'package:gym_app/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo(
    userRepo: ApiUserRepo(
      apiClient: ApiClient.instance,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            authRepo: firebaseAuthRepo,
          )..checkAuth(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Gim-fit',
            debugShowCheckedModeBanner: false,
            theme: lightMode,
            darkTheme: darkMode,
            routerConfig: getAppRouter(context),
            builder: (context, child) {
              return BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    showMessage(
                      context,
                      state.message,
                      type: MessageType.error,
                    );
                  }
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
