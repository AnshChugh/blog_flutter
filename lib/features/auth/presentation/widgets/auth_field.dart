import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  const AuthField({super.key, required this.hintText, this.isPass = false});
  final String hintText;
  final bool isPass;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(label: Text(hintText)),
      obscureText: isPass,
    );
  }
}
