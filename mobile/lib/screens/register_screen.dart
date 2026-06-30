import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final address = _addressController.text.trim();
    
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, заполните все поля')));
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, введите корректный адрес эл. почты')));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пароли не совпадают')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.register(email, password, name, null, address);

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
              Text('Создать аккаунт', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('Зарегистрируйтесь, чтобы начать', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xl),
              CustomTextField(
                label: 'Имя и фамилия',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
              ),
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
              CustomTextField(
                label: 'Подтверждение пароля',
                controller: _confirmPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
              ),
              CustomTextField(
                label: 'Адрес доставки',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'Создать аккаунт',
                onPressed: isLoading ? null : _register,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Уже есть аккаунт?', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Text('Войти', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
