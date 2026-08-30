import 'package:flutter/material.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';

enum FormType { cardioForm, strengthForm }

class SwitcherForm extends StatelessWidget {
  const SwitcherForm({
    super.key,
    required this.showForm,
    required this.onShowForm,
    required this.onCloseForm,
    required this.weigthController,
    required this.repsController,
    required this.minutesController,
    required this.distanceController,
    this.suggestedWeightUnit,
    required this.formType,
    required this.onSubmit,
    required this.isEditing,
    required this.isLoading,
  });

  final bool showForm;
  final VoidCallback onShowForm;
  final VoidCallback onCloseForm;
  final FormType formType;
  final TextEditingController weigthController;
  final TextEditingController repsController;
  final TextEditingController minutesController;
  final TextEditingController distanceController;
  final String? suggestedWeightUnit;
  final VoidCallback onSubmit;
  final bool isEditing;
  final bool isLoading;

  String get _formTitle {
    if (formType == FormType.cardioForm) {
      return isEditing ? "Editar sesión" : "Registrar sesión";
    }

    return isEditing ? "Editar serie" : "Registrar serie";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 50),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: showForm ? _buildFormCard(context) : _buildAddButton(context),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return KeyedSubtree(
      key: const ValueKey('addButton'),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Material(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onShowForm,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formType == FormType.strengthForm
                        ? 'Registrar serie'
                        : 'Registrar sesión',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return KeyedSubtree(
      key: const ValueKey('formCard'),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // ---------------------------------------------
                // ----------- HEADER DEL FORMULARIO -----------
                // ---------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onCloseForm,
                      child: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /** Formulario de Peso y Repeticiones */
                if (formType == FormType.strengthForm) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- SECCIÓN PESO ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PESO",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextfield(
                                    controller: weigthController,
                                    hintText: "0",
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    (suggestedWeightUnit != null &&
                                            suggestedWeightUnit!.isNotEmpty)
                                        ? suggestedWeightUnit!
                                        : "Kg",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Divisor vertical
                      Container(
                        height: 45,
                        width: 1,
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),

                      // --- SECCIÓN REPETICIONES ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "REPETICIONES",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextfield(
                                    controller: repsController,
                                    hintText: "0",
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    "Reps",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                if (formType == FormType.cardioForm) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- MINUTOS ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MINUTOS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextfield(
                                    controller: minutesController,
                                    hintText: "0",
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    "min",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Divisor vertical
                      Container(
                        height: 45,
                        width: 1,
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),

                      // --- DISTANCIA ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DISTANCIA",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextfield(
                                    controller: distanceController,
                                    hintText: "0",
                                    obscureText: false,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    "Km",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                /** Botón para guardar serie */
                MyButton(
                  onTap: isLoading ? null : onSubmit,
                  text: isLoading
                      ? "Guardando..."
                      : isEditing
                      ? "Actualizar"
                      : formType == FormType.cardioForm
                      ? "Registrar sesión"
                      : "Registrar serie",
                  type: MyButtonType.primary,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
