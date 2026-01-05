import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../core/theme_provider.dart';
import '../../../../shared/menu_share.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      drawer: MediaQuery.of(context).size.width < 800 ? MenuShared(user: authState.user) : null,
      body: LayoutBuilder(
        builder: (context, constraints){
          final bool isTablet = constraints.maxWidth >= 800;

          if (isTablet) {
            return Row(
              children: [
                Container(
                  width: 280,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: MenuShared(user: authState.user),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'Light',
                        icon: Icons.light_mode,
                        value: AppThemeMode.light,
                        current: currentMode,
                      ),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'Dark',
                        icon: Icons.dark_mode,
                        value: AppThemeMode.dark,
                        current: currentMode,
                      ),
                      _buildThemeOption(
                        context: context,
                        ref: ref,
                        title: 'System',
                        icon: Icons.brightness_auto,
                        value: AppThemeMode.system,
                        current: currentMode,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildThemeOption(
                  context: context,
                  ref: ref,
                  title: 'Light',
                  icon: Icons.light_mode,
                  value: AppThemeMode.light,
                  current: currentMode,
                ),
                _buildThemeOption(
                  context: context,
                  ref: ref,
                  title: 'Dark',
                  icon: Icons.dark_mode,
                  value: AppThemeMode.dark,
                  current: currentMode,
                ),
                _buildThemeOption(
                  context: context,
                  ref: ref,
                  title: 'System',
                  icon: Icons.brightness_auto,
                  value: AppThemeMode.system,
                  current: currentMode,
                ),
              ],
            );
          }
        },
      ),

    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required AppThemeMode value,
    required AppThemeMode current,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: RadioListTile<AppThemeMode>(
        title: Text(title),
        secondary: Icon(icon),
        value: value,
        groupValue: current,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (val) {
          ref.read(themeProvider.notifier).setTheme(val!);
        },
      ),
    );
  }
}