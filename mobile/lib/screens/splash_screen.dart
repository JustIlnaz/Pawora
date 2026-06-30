import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PAWORA',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Icon(Icons.pets, size: 64, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
