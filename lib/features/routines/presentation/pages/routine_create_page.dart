import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_create/routine_create_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_create/routine_create_state.dart';

class RoutineCreatePage extends StatefulWidget {
  const RoutineCreatePage({super.key});

  @override
  State<RoutineCreatePage> createState() => _RoutineCreatePageState();
}

class _RoutineCreatePageState extends State<RoutineCreatePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutineCreateCubit, RoutineCreateState>(
      listener: (context, state) {
        // DEVUELVE A LA PÁGINA ANTERIOR UNA VEZ CREADO LA RUTINA
        if (state.isCreated && state.routineId != null) {
          context.pop(true);
        }

        // MUESTRA ERROR
        if (state.errorMessage != null) {
          if (state.fieldErrors == null || state.fieldErrors!.isEmpty) {
            showMessage(
              context,
              state.errorMessage!,
              type: MessageType.error,
            );
          }
        }
      },
      builder: (context, state) {
        final isCreating = state.isCreating;

        String? nameError;

        if (state.fieldErrors != null) {
          nameError = state.fieldErrors!['name']?.toString();
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && context.canPop()) {
              context.pop(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text("Crear rutina"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isCreating
                    ? null
                    : () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  MyTextfield(
                    controller: _nameController,
                    hintText: "Nombre de la rutina",
                    obscureText: false,
                    errorText: nameError,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: MyButton(
                      text: "Crear rutina",
                      isLoading: isCreating,
                      type: MyButtonType.primary,
                      onTap: () {
                        context.read<RoutineCreateCubit>().createRoutine(
                          name: _nameController.text.trim(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
