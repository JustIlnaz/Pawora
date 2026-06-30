import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при выборе изображения')),
        );
      }
    }
  }

  void _save() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    await provider.updateProfile(_nameController.text, _phoneController.text, _imageFile);
    
    if (!mounted) return;
    await Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();

    if (mounted) {
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль успешно обновлен')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;
    final user = context.read<AuthProvider>().user;

    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(File(_imageFile!.path));
    } else if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(ApiClient.getFullImageUrl(user.avatarUrl));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage: imageProvider,
                      child: imageProvider == null 
                          ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            CustomTextField(
              label: 'Имя и фамилия',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            CustomTextField(
              label: 'Номер телефона',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            CustomTextField(
              label: 'Эл. почта',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              readOnly: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              text: 'Сохранить изменения',
              onPressed: isLoading ? null : _save,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
