import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list_state.dart';

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
    return BlocProvider(
      create: (_) => RoutineListCubit(
        routineRepo: ApiRoutineRepo(),
      ),
      // TODO: Completar la página para crear rutina
      
      /*child: BlocConsumer<RoutineListCubit, RoutineListState>(
        listener: (context, state) {
          // RUTINA CREADA CORRECTAMENTE
          if (state is RoutineCreated) {
            context.pop(true);
          }

          // ERROR
          if (state is RoutineListError) {
            // Si no hay errores específicos de campos,
            // mostramos un SnackBar
            if (state.fieldErrors == null || state.fieldErrors!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          // SABEMOS SI ESTÁ CREANDO
          final isCreating = state is RoutineListCreating;

          // ERROR ESPECÍFICO DEL NOMBRE
          String? nameError;

          if (state is RoutineListError) {
            nameError = state.fieldErrors?['name']?.toString();
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text('Crear rutina'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      onTap: () {
                        context.read<RoutineListCubit>().createRoutine(
                          name: _nameController.text.trim(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ), */
    );
  }
}
