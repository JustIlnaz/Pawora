import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/pet_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).fetchPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final petProvider = context.watch<PetProvider>();

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.surfaceContainerHighest,
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? NetworkImage(ApiClient.getFullImageUrl(user.avatarUrl)) as ImageProvider
                    : null,
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? Text(user.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 32))
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(user.fullName, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xl),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Мои питомцы', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/add_pet'),
                    child: const Text('+ Добавить', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            if (petProvider.pets.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  scrollDirection: Axis.horizontal,
                  itemCount: petProvider.pets.length,
                  itemBuilder: (context, index) {
                    return PetCard(pet: petProvider.pets[index]);
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('Питомцы пока не добавлены.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            
            const SizedBox(height: AppSpacing.lg),
            if (user.role == 'Admin' || user.role == 'ShopOwner' || user.role == '2' || user.role == '1')
              _buildMenuTile(context, Icons.admin_panel_settings, 'Панель управления', () => Navigator.pushNamed(context, '/admin')),
            _buildMenuTile(context, Icons.receipt_long, 'Мои заказы', () => Navigator.pushNamed(context, '/orders')),
            _buildMenuTile(context, Icons.favorite_border, 'Избранное', () => Navigator.pushNamed(context, '/favorites')),
            _buildMenuTile(context, Icons.location_on_outlined, 'Адреса доставки', () => Navigator.pushNamed(context, '/addresses')),
            _buildMenuTile(context, Icons.payment, 'Способы оплаты', () => Navigator.pushNamed(context, '/payment_methods')),
            _buildMenuTile(context, Icons.settings, 'Настройки', () => Navigator.pushNamed(context, '/settings')),
            _buildMenuTile(context, Icons.help_outline, 'Помощь и поддержка', () => Navigator.pushNamed(context, '/help')),
            _buildMenuTile(
              context,
              Icons.logout,
              'Выйти из аккаунта',
              () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выход из аккаунта'),
                    content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена', style: TextStyle(color: AppColors.onSurface)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Выйти', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                  }
                }
              },
              isDestructive: true,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : AppColors.onSurface;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.errorContainer.withValues(alpha: 0.2) : AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
