import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 120, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'PAWORA',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Любимый магазин вашего питомца",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: 'Продолжить',
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
