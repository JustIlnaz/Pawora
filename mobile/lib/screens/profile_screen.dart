import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
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
        title: Text(context.translate('profile')),
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
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xl),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.translate('my_pets'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/add_pet'),
                    child: Text(context.translate('add_pet'), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(context.translate('no_pets'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            
            const SizedBox(height: AppSpacing.lg),
            if (user.role == 'Admin' || user.role == 'ShopOwner' || user.role == '2' || user.role == '1')
              _buildMenuTile(context, Icons.admin_panel_settings, context.translate('admin_panel'), () => Navigator.pushNamed(context, '/admin')),
            _buildMenuTile(context, Icons.receipt_long, context.translate('my_orders'), () => Navigator.pushNamed(context, '/orders')),
            _buildMenuTile(context, Icons.favorite_border, context.translate('favorites'), () => Navigator.pushNamed(context, '/favorites')),
            _buildMenuTile(context, Icons.location_on_outlined, context.translate('delivery_addresses'), () => Navigator.pushNamed(context, '/addresses')),
            _buildMenuTile(context, Icons.payment, context.translate('payment_methods'), () => Navigator.pushNamed(context, '/payment_methods')),
            _buildMenuTile(context, Icons.settings, context.translate('settings'), () => Navigator.pushNamed(context, '/settings')),
            _buildMenuTile(context, Icons.help_outline, context.translate('help_support'), () => Navigator.pushNamed(context, '/help')),
            _buildMenuTile(
              context,
              Icons.logout,
              context.translate('logout'),
              () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.translate('logout_confirm_title')),
                    content: Text(context.translate('logout_confirm_msg')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.translate('cancel'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(context.translate('logout_btn'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
    final color = isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
