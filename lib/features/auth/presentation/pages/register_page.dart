import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';

import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_states.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({
    super.key,
    required this.togglePages,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  late final authCubit = context.read<AuthCubit>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  void register() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = pwController.text;
    final confirmPassword = confirmPwController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage(
        context,
        "Please fill in all fields",
        type: MessageType.error,
      );
      return;
    }

    if (password != confirmPassword) {
      showMessage(
        context,
        "Passwords do not match",
        type: MessageType.error,
      );
      return;
    }

    authCubit.register(name, email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  Text(
                    "GymFit",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),

                  const SizedBox(height: 25),

                  MyTextfield(
                    controller: nameController,
                    hintText: "Nombres",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  MyTextfield(
                    controller: emailController,
                    hintText: "E-mail",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  MyTextfield(
                    controller: pwController,
                    hintText: "Contraseña",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  MyTextfield(
                    controller: confirmPwController,
                    hintText: "Confirmar contraseña",
                    obscureText: true,
                  ),

                  const SizedBox(height: 25),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return MyButton(
                        onTap: isLoading ? null : register,
                        text: "Crear cuenta",
                        type: MyButtonType.primary,
                        isLoading: isLoading,
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿Ya tienes una cuenta?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Inicia sesión",
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
