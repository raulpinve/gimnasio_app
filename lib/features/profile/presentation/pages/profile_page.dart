import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/profile/presentation/cubits/stats/stat_state.dart';
import 'package:gym_app/features/profile/presentation/cubits/stats/stats_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _getStreakEmoji(int streak) {
    if (streak == 0) return '❄️'; // Sin racha / Frío
    if (streak < 3) return '⚡'; // Racha pequeña / Activándose
    if (streak < 7) return '🔥'; // Buena racha / Fuego
    if (streak < 15) return '👑'; // Racha excelente
    return '🏆'; // Racha legendaria (más de 15 días)
  }

  Future<void> _onRefreshStats() async {
    await context.read<StatsCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().currentUser;
    final firstName = user?.firstName;

    final buttonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    const buttonTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
            style: buttonStyle,
            child: const Icon(
              Icons.logout_outlined,
              size: 18,
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 176,
                height: 176,
                padding: const EdgeInsets.all(6), // espacio para el anillo
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      firstName != null && firstName.isNotEmpty
                          ? firstName[0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            Center(
              child: Text(
                "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 8),

            Center(
              child: Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            SizedBox(height: 28),

            BlocBuilder<StatsCubit, StatState>(
              builder: (context, state) {
                // CARGA INICIAL
                if (state is StatsLoading) {
                  return skeletonLoader();
                }

                // ERROR
                if (state is StatsError) {
                  return RefreshableContent(
                    onRefresh: _onRefreshStats,
                    child: Text(state.message),
                  );
                }

                // STATS CARGADOS
                if (state is StatsLoaded) {
                  final stats = state.stats;

                  // NO HAY ESTADÍSTICAS
                  if (stats.totalWorkouts == 0 && stats.currentStreak == 0) {
                    return SizedBox.shrink();
                  }

                  // STATS DISPONIBLES
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ENTRENAMIENTOS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stats.totalWorkouts}',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "RACHA",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stats.currentStreak} ${_getStreakEmoji(stats.currentStreak)}',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: 14),

            ElevatedButton.icon(
              onPressed: () async {
                final updated = await context.push<bool>('/profile/update');
                if (updated == true && context.mounted) {
                  showMessage(
                    context,
                    'Perfil actualizado correctamente',
                    type: MessageType.success,
                  );
                }
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              label: const Text(
                "Editar perfil",
                style: buttonTextStyle,
              ),
              style: buttonStyle,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Widget skeletonLoader() {
  return Center(
    child: CircularProgressIndicator(),
  );
}
