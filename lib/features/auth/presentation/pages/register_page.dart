import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function() togglePages;
  const RegisterPage({
    super.key,
    required this.togglePages,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Text("Register page");
  }
}
