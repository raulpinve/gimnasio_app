import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_state.dart';

void showCreateRoutineBottomSheet(BuildContext context) {
  final routineListCubit = context.read<RoutineListCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return BlocProvider.value(
        value: routineListCubit,
        child: const CreateRoutineBottomSheet(),
      );
    },
  );
}

class CreateRoutineBottomSheet extends StatefulWidget {
  const CreateRoutineBottomSheet({super.key});

  @override
  State<CreateRoutineBottomSheet> createState() =>
      _CreateRoutineBottomSheetState();
}

class _CreateRoutineBottomSheetState extends State<CreateRoutineBottomSheet> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutineListCubit, RoutineListState>(
      listener: (context, state) {
        if (state is! RoutinesListLoaded) {
          return;
        }

        if (state.isCreating) {
          return;
        }

        if (state.fieldErrors != null && state.fieldErrors!.isNotEmpty) {
          return;
        }

        if (state.errorMessage != null) {
          showMessage(
            context,
            state.errorMessage!,
            type: MessageType.error,
          );
          return;
        }

        Navigator.of(context).pop();

        showMessage(
          context,
          'Rutina creada correctamente',
          type: MessageType.success,
        );
      },
      builder: (context, state) {
        final isCreating = state is RoutinesListLoaded && state.isCreating;

        String? nameError;
        String? generalError;

        if (state is RoutinesListLoaded) {
          final hasFieldErrors =
              state.fieldErrors != null && state.fieldErrors!.isNotEmpty;

          nameError = state.fieldErrors?['name']?.toString();
          generalError = hasFieldErrors ? null : state.errorMessage;
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle visual
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  Text(
                    'Crear rutina',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 24),

                  MyTextfield(
                    controller: _nameController,
                    hintText: 'Nombre de la rutina',
                    obscureText: false,
                    errorText: nameError,
                  ),

                  if (generalError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      generalError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: MyButton(
                      text: 'Crear rutina',
                      isLoading: isCreating,
                      type: MyButtonType.primary,
                      onTap: isCreating
                          ? null
                          : () {
                              context.read<RoutineListCubit>().createRoutine(
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
