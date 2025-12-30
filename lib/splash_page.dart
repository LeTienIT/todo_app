import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    //final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      if (!next.isLoading) {
        if (next.user != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
