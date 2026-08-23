import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';

import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/profile/presentation/cubits/profile/profile_update_cubit.dart';
import 'package:gym_app/features/profile/presentation/cubits/profile/profile_update_state.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthCubit>().currentUser;

    _firstNameController.text = user?.firstName ?? '';
    _lastNameController.text = user?.lastName ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    final profileBody = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
    };

    context.read<ProfileUpdateCubit>().updateProfile(
      profileBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const BackButton(),
        title: const Text('Editar perfil'),
      ),
      body: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
        listener: (context, state) {
          if (state.isUpdated && state.updatedUser != null) {
            context.read<AuthCubit>().updateCurrentUser(
              state.updatedUser!,
            );

            context.pop(true);
          }
        },
        child: BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  MyTextfield(
                    controller: _firstNameController,
                    hintText: "Nombres",
                    obscureText: false,
                    errorText: state.fieldErrors?['firstName']?.toString(),
                  ),

                  const SizedBox(height: 12),

                  MyTextfield(
                    controller: _lastNameController,
                    hintText: "Apellidos",
                    obscureText: false,
                    errorText: state.fieldErrors?['lastName']?.toString(),
                  ),

                  const SizedBox(height: 12),

                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  MyButton(
                    onTap: state.isUpdating ? null : _updateProfile,
                    text: "Guardar cambios",
                    isLoading: state.isUpdating,
                    type: MyButtonType.primary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
