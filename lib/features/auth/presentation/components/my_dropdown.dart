import 'package:flutter/material.dart';

class MyDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final ValueChanged<T?>? onChanged;

  const MyDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,

      // Mantiene el color del texto seleccionado igual al hint o al tema
      style: TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary,
        fontSize: 16,
      ),

      // Color del menú flotante al desplegarse
      dropdownColor: Theme.of(context).colorScheme.secondary,

      // Icono personalizado y estilizado
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),

      // Configuración obligatoria para que no altere la altura interna
      isDense: true,

      decoration: InputDecoration(
        // Relleno interno idéntico al TextField por defecto
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),

        // border when unselected (Copia exacta)
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),

        // border when selected (Copia exacta)
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),

        // Evita deformaciones visuales en estados intermedios
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        hintText: hintText,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
      ),
    );
  }
}
