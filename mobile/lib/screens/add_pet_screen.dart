import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';
import '../services/api_client.dart';
import '../providers/pet_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  String _selectedSpecies = 'Dog';
  String? _selectedBirthDateIso;
  String _imageUrl = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1';
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Pet? _existingPet;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Pet) {
        _existingPet = args;
        _nameController.text = _existingPet!.name;
        _breedController.text = _existingPet!.breed ?? '';
        _selectedSpecies = _existingPet!.species;
        _selectedBirthDateIso = _existingPet!.birthDate;
        if (_selectedBirthDateIso != null) {
          try {
            final parsedDate = DateTime.parse(_selectedBirthDateIso!);
            _birthDateController.text = DateFormat('yyyy-MM-dd').format(parsedDate);
          } catch (_) {
            _birthDateController.text = _selectedBirthDateIso!;
          }
        }
        if (_existingPet!.imageUrl != null && _existingPet!.imageUrl!.isNotEmpty) {
          _imageUrl = ApiClient.getFullImageUrl(_existingPet!.imageUrl);
        }
      }
      _isInitialized = true;
    }
  }

  final List<String> _implementedSvgs = ['dog', 'cat', 'bird', 'fish', 'hamster', 'rabbit'];
  final List<String> _speciesList = ['Dog', 'Cat', 'Bird', 'Fish', 'Hamster', 'Rabbit'];
  final Map<String, String> _speciesTranslation = {
    'Dog': 'Собака',
    'Cat': 'Кошка',
    'Bird': 'Птица',
    'Fish': 'Рыба',
    'Hamster': 'Хомяк',
    'Rabbit': 'Кролик',
  };
  final Map<String, IconData> _speciesIcons = {
    'Dog': Icons.sports_soccer,
    'Cat': Icons.bedtime,
    'Bird': Icons.music_note,
    'Fish': Icons.waves,
    'Hamster': Icons.grain,
    'Rabbit': Icons.grass,
  };
  final Map<String, List<Color>> _speciesGradients = {
    'Dog': [Color(0xFFFF9F43), Color(0xFFFF5252)],
    'Cat': [Color(0xFF9B5DE5), Color(0xFFF15BB5)],
    'Bird': [Color(0xFF00F5D4), Color(0xFF00BBF9)],
    'Fish': [Color(0xFF00BBF9), Color(0xFF3B82F6)],
    'Hamster': [Color(0xFFFFEE58), Color(0xFFFFA726)],
    'Rabbit': [Color(0xFFF8BBD0), Color(0xFFEC407A)],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          // Set _imageUrl to empty string so it doesn't conflict when sending the local file later, 
          // although we only pass the path.
          _imageUrl = ''; 
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

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryContainer,
              onPrimary: Colors.white,
              surface: AppColors.surfaceContainerHigh,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDateIso = picked.toUtc().toIso8601String();
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() async {
    final name = _nameController.text.trim();
    final breed = _breedController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите имя питомца.')),
      );
      return;
    }

    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    if (_existingPet != null) {
      await petProvider.updatePet(
        _existingPet!.id,
        name,
        _selectedSpecies,
        breed.isEmpty ? null : breed,
        _imageFile,
        _selectedBirthDateIso,
      );
    } else {
      await petProvider.addPet(
        name,
        _selectedSpecies,
        breed.isEmpty ? null : breed,
        _imageFile,
        _selectedBirthDateIso,
      );
    }

    if (mounted) {
      if (petProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(petProvider.error!)),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Удалить питомца?'),
        content: const Text('Вы уверены, что хотите удалить этого питомца? Это действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      await petProvider.deletePet(_existingPet!.id);
      if (mounted) {
        if (petProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(petProvider.error!)),
          );
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingPet != null ? 'Редактировать питомца' : 'Добавить питомца'),
        actions: _existingPet != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: _confirmDelete,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      backgroundImage: _imageFile != null
                          ? FileImage(File(_imageFile!.path)) as ImageProvider
                          : NetworkImage(_imageUrl),
                    ),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomTextField(
                label: 'Имя питомца',
                hint: 'Введите имя вашего питомца',
                controller: _nameController,
                prefixIcon: Icons.pets,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Вид животного',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.2,
                ),
                itemCount: _speciesList.length,
                itemBuilder: (context, index) {
                  final species = _speciesList[index];
                  final isSelected = _selectedSpecies == species;
                  final icon = _speciesIcons[species] ?? Icons.pets;
                  final name = _speciesTranslation[species] ?? species;
                  final gradient = _speciesGradients[species] ?? [AppColors.surfaceContainer, AppColors.surfaceContainerHigh];

                  return Card(
                    color: isSelected
                        ? AppColors.primaryContainer.withValues(alpha: 0.1)
                        : AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSpecies = species;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? gradient
                                    : [AppColors.surfaceContainerHighest, AppColors.surfaceBright],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: gradient.last.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ] : null,
                            ),
                            child: _implementedSvgs.contains(species.toLowerCase())
                                ? SvgPicture.asset(
                                    'assets/icons/${species.toLowerCase()}.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: ColorFilter.mode(
                                      isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : Icon(
                                    icon,
                                    size: 20,
                                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                  ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Порода',
                hint: 'например, Золотистый ретривер',
                controller: _breedController,
                prefixIcon: Icons.info_outline,
              ),
              CustomTextField(
                label: 'Дата рождения',
                hint: 'Выберите дату рождения',
                controller: _birthDateController,
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: () => _selectBirthDate(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: _existingPet != null ? 'Сохранить изменения' : 'Добавить питомца',
                isLoading: petProvider.isLoading,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
