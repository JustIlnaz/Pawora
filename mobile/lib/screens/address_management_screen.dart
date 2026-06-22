import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  void _showAddressDialog({String? id, String? initialText, bool isDefault = false}) {
    final textController = TextEditingController(text: initialText);
    bool isDefaultChecked = isDefault;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    id == null ? 'Новый адрес' : 'Редактировать адрес',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Адрес доставки',
                    controller: textController,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CheckboxListTile(
                    title: const Text('Сделать основным адресом', style: TextStyle(color: AppColors.onSurface)),
                    value: isDefaultChecked,
                    activeColor: AppColors.primary,
                    checkColor: AppColors.onPrimary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() {
                        isDefaultChecked = val ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    text: 'Сохранить',
                    onPressed: () async {
                      final text = textController.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пожалуйста, введите адрес')),
                        );
                        return;
                      }

                      final provider = Provider.of<AddressProvider>(context, listen: false);
                      bool success;
                      if (id == null) {
                        success = await provider.addAddress(text, isDefaultChecked);
                      } else {
                        success = await provider.updateAddress(id, text, isDefaultChecked);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (!success && provider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error!)),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Адреса доставки'),
      ),
      body: provider.isLoading && provider.addresses.isEmpty
          ? const LoadingState()
          : provider.error != null && provider.addresses.isEmpty
              ? ErrorState(
                  message: provider.error!,
                  onRetry: () => provider.fetchAddresses(),
                )
              : provider.addresses.isEmpty
                  ? EmptyState(
                      icon: Icons.location_off_outlined,
                      message: 'У вас пока нет сохраненных адресов.',
                    )
                  : RefreshIndicator(
                      onRefresh: provider.fetchAddresses,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: provider.addresses.length,
                        itemBuilder: (context, index) {
                          final address = provider.addresses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            color: AppColors.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: address.isDefault ? AppColors.primary : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              key: ValueKey(address.id),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                                            const SizedBox(width: AppSpacing.sm),
                                            if (address.isDefault)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryContainer,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Основной',
                                                  style: TextStyle(
                                                    color: AppColors.onPrimaryContainer,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          address.addressText,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!address.isDefault)
                                        IconButton(
                                          icon: const Icon(Icons.star_border, color: AppColors.onSurfaceVariant),
                                          onPressed: () => provider.setDefaultAddress(address.id),
                                          tooltip: 'Сделать основным',
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant),
                                        onPressed: () => _showAddressDialog(
                                          id: address.id,
                                          initialText: address.addressText,
                                          isDefault: address.isDefault,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Удаление адреса'),
                                              content: const Text('Вы уверены, что хотите удалить этот адрес?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Отмена', style: TextStyle(color: AppColors.onSurface)),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Удалить', style: TextStyle(color: AppColors.error)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await provider.deleteAddress(address.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: provider.addresses.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: PrimaryButton(
                  text: 'Добавить новый адрес',
                  onPressed: () => _showAddressDialog(),
                ),
              ),
            )
          : null,
    );
  }
}
