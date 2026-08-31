import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/features/auth/presentation/components/google_sign_in_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_states.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  bool isResettingPassword = false;

  // auth cubit
  late final authCubit = context.read<AuthCubit>();

  // login button pressed
  void login() {
    // prepare email & pw
    final String email = emailController.text;
    final String pw = pwController.text;

    // ensure that the fields are filled
    if (email.isNotEmpty && pw.isNotEmpty) {
      // login!
      authCubit.login(email, pw);
    }
    // fields are empty
    else {
      showMessage(
        context,
        "Please enter both email & password",
        type: MessageType.error,
      );
    }
  }

  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isResettingPassword = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                "¿Olvidaste tu contraseña?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 320,
                    child: MyTextfield(
                      controller: emailController,
                      hintText: "Ingresa tu correo electrónico",
                      obscureText: false,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isResettingPassword
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: isResettingPassword
                      ? null
                      : () async {
                          setDialogState(() {
                            isResettingPassword = true;
                          });

                          final navigator = Navigator.of(dialogContext);

                          final message = await authCubit.forgotPassword(
                            emailController.text.trim(),
                          );

                          if (!mounted) return;

                          navigator.pop();

                          showMessage(
                            context,
                            message,
                            type: MessageType.info,
                          );

                          emailController.clear();
                        },
                  child: isResettingPassword
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Restablecer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    // Scaffold
    return Scaffold(
      // Body
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 70),
                  // name of the app
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 26,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "GymFit",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // email textfield
                  MyTextfield(
                    controller: emailController,
                    hintText: "E-mail",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // pw textfield
                  MyTextfield(
                    controller: pwController,
                    hintText: "Contraseña",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // forgot pw
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => openForgotPasswordBox(),
                        child: Text(
                          "¿Olvidó la contraseña?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // login button
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return MyButton(
                        onTap: isLoading ? null : login,
                        text: 'Iniciar sesión',
                        type: MyButtonType.primary,
                        isLoading: isLoading,
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.15),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "O continúa con",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.15),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyGoogleSignInButton(
                        onTap: () async {
                          authCubit.signInWithGoogle();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ¿No tienes una cuenta? Registrate ahora
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿No tienes una cuenta?",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Crea una ahora",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary, // antes: primary
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
