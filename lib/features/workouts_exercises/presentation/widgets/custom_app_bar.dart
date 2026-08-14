import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // // 1. Declaras las variables como finales
  // final VoidCallback onBotonUnoPressed;
  // final VoidCallback onBotonDosPressed;
  // final VoidCallback onBotonTresPressed;
  // final String titulo; // Ejemplo de cómo pasar un dato de tipo texto

  // // 2. Las agregas al constructor (puedes usarlas como requeridas o nombradas)
  // const CustomAppBar({
  //   super.key,
  //   required this.titulo,
  //   required this.onBotonUnoPressed,
  //   required this.onBotonDosPressed,
  //   required this.onBotonTresPressed,
  // });

  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.check),
          color: Colors.green.shade900,
          style: IconButton.styleFrom(
            backgroundColor: Colors.green.shade100,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(32, 32),
            padding: const EdgeInsets.all(6),
          ),
          iconSize: 18,
        ),

        const SizedBox(width: 6),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.close),
          color: Colors.red.shade900,
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(32, 32),
            padding: const EdgeInsets.all(6),
          ),
          iconSize: 18,
        ),

        const SizedBox(width: 18),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
