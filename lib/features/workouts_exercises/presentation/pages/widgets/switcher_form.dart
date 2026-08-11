import 'package:flutter/material.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';

class SwitcherForm extends StatelessWidget {
  const SwitcherForm({
    super.key,
    required this.showForm,
    required this.onShowForm,
    required this.onCloseForm,
    required this.weigthController,
    required this.repsController,
  });

  final bool showForm;
  final VoidCallback onShowForm;
  final VoidCallback onCloseForm;
  final TextEditingController weigthController;
  final TextEditingController repsController;

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
      child: showForm ? _buildFormCard(context) : _buildAddButton(),
    );
  }

  Widget _buildAddButton() {
    return KeyedSubtree(
      key: const ValueKey('addButton'),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: TextButton.icon(
          onPressed: onShowForm,
          icon: Icon(Icons.add),
          label: Text("Registrar serie"),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('formCard'),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                width: 1.5,
              ),
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
                      "Registrar serie",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECCIÓN PESO ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PESO",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
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
                              const SizedBox(
                                width: 38,
                                child: Text(
                                  "Kg",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9CA3AF),
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
                      color: const Color(0xFFE5E7EB),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    // --- SECCIÓN REPETICIONES ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "REPETICIONES",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
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
                              const SizedBox(
                                width: 38,
                                child: Text(
                                  "Reps",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9CA3AF),
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
                const SizedBox(height: 24),

                /** Botón para guardar serie */
                MyButton(
                  onTap: () {
                    // Tu lógica para guardar
                  },
                  text: "Guardar cambios",
                  type: MyButtonType.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
