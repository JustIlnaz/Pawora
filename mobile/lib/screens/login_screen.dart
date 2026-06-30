import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, заполните все поля')));
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, введите корректный адрес эл. почты')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(email, password);

    if (mounted) {
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.error!)));
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  'PAWORA',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('С возвращением', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('Войдите, чтобы продолжить', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xl),
              CustomTextField(
                label: 'Эл. почта',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                label: 'Пароль',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Забыли пароль?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'Войти',
                onPressed: isLoading ? null : _login,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Нет аккаунта?", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text('Зарегистрироваться', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
