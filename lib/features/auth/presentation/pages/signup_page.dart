import 'package:blog_flutter/core/theme/app_pellete.dart';
import 'package:blog_flutter/features/auth/presentation/widgets/auth_field.dart';
import 'package:blog_flutter/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign Up.',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const AuthField(hintText: 'Name'),
            const SizedBox(
              height: 15,
            ),
            const AuthField(hintText: 'Email'),
            const SizedBox(
              height: 15,
            ),
            const AuthField(
              hintText: 'Password',
              isPass: true,
            ),
            const SizedBox(
              height: 20,
            ),
            const AuthGradientButton(),
            const SizedBox(
              height: 20,
            ),
            RichText(
                text: TextSpan(
                    text: 'Already have an Account?  ',
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                  TextSpan(
                      text: 'Sign In',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppPallete.gradient2,
                          fontWeight: FontWeight.bold))
                ])),
          ],
        ),
      ),
    );
  }
}
