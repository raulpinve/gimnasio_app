/*
  LOGIN PAGE UI

  On this page, a user can login with their: 
  - email
  - pw

  ----------------------------------------------------------------------------------------
  Once the user successfully logs in, they will be directed to homepage

  if(user doesn't have an account, they can go to register page to create one)
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/auth/presentation/components/google_sign_in_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email & password")),
      );
    }
  }

  // forgot password
  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (builder) => AlertDialog(
        title: const Text("Forgot Password?"),
        content: MyTextfield(
          controller: emailController,
          hintText: "Enter email...",
          obscureText: false,
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          // reset button
          TextButton(
            onPressed: () async {
              // 1. Guardamos la referencia al navigator antes del async request
              final navigator = Navigator.of(context);

              String message = await authCubit.forgotPassword(
                emailController.text,
              );

              // 2. Verificamos que el widget siga montado antes de usar el contexto
              if (!mounted) return;

              if (message == "Password reset email! Check your inbox.") {
                navigator.pop(); // Usamos la referencia guardada
                emailController.clear();
              }

              // El contexto aquí ya está protegido por el chequeo de 'mounted'
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
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
                  Text(
                    "Gym-fit",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // email textfield
                  MyTextfield(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // pw textfield
                  MyTextfield(
                    controller: pwController,
                    hintText: "password",
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
                          "Forgot password?",
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
                  MyButton(onTap: login, text: "LOGIN"),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text("Or sign in with"),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.tertiary,
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

                  // don't have an account? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Register now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
