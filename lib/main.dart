import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:riverpod_todo_app/core/theme.dart';
import 'core/providers.dart';
import 'core/app_router.dart';
import 'core/theme_provider.dart';
import 'firebase_options.dart';
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeDataProvider);

    return MaterialApp.router(
      title: 'To do app',
      theme: theme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}