import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 12,
          top: 10,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 80,
              child: BottomNavigationBar(
                elevation: 0,
                currentIndex: currentIndex,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: Colors.grey.shade400,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                onTap: onTap,
                items: [
                  BottomNavigationBarItem(
                    icon: const SizedBox(
                      height: 40,
                      child: Icon(
                        Icons.checklist_rtl_rounded,
                        size: 25,
                      ),
                    ),
                    activeIcon: const SizedBox(
                      height: 40,
                      child: Icon(
                        Icons.checklist_rounded,
                        size: 25,
                      ),
                    ),
                    label: 'Rutinas',
                  ),
                  BottomNavigationBarItem(
                    icon: SizedBox(
                      height: 40,
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_fire_department_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    activeIcon: SizedBox(
                      height: 40,
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),
                    ),
                    label: 'Workouts',
                  ),
                  BottomNavigationBarItem(
                    icon: const SizedBox(
                      height: 40,
                      child: Icon(
                        Icons.person_outline,
                        size: 25,
                      ),
                    ),
                    activeIcon: const SizedBox(
                      height: 40,
                      child: Icon(
                        Icons.person,
                        size: 25,
                      ),
                    ),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
