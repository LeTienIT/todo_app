import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';


class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      if (prev?.user == null && next.user != null) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Column(
        children: [
          TextField(controller: emailController),
          TextField(controller: passwordController),
          TextField(controller: nameController),
          ElevatedButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).register(
                emailController.text,
                passwordController.text,
                nameController.text,
              );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
