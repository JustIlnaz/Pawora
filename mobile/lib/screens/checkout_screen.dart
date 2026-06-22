import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/address_provider.dart';
import '../providers/product_provider.dart';
import '../providers/payment_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'add_card_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _manualAddressController = TextEditingController();
  String? _selectedAddressId;
  String _paymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      await paymentProvider.loadCards();
      if (paymentProvider.cards.isNotEmpty && _paymentMethod == 'card') {
        setState(() {
          _paymentMethod = paymentProvider.cards.firstWhere((c) => c.isDefault, orElse: () => paymentProvider.cards.first).id;
        });
      } else if (paymentProvider.cards.isEmpty && _paymentMethod == 'card') {
        setState(() {
          _paymentMethod = 'cash';
        });
      }
      await addressProvider.fetchAddresses();
      if (addressProvider.addresses.isNotEmpty) {
        final def = addressProvider.defaultAddress;
        setState(() {
          _selectedAddressId = def?.id ?? addressProvider.addresses.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _manualAddressController.dispose();
    super.dispose();
  }

  void _showAddAddressDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить новый адрес'),
          content: CustomTextField(
            label: 'Адрес доставки',
            controller: textController,
            prefixIcon: Icons.location_on_outlined,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: AppColors.onSurface)),
            ),
            TextButton(
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пожалуйста, введите адрес')),
                  );
                  return;
                }

                final provider = Provider.of<AddressProvider>(context, listen: false);
                final success = await provider.addAddress(text, true);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success && provider.addresses.isNotEmpty) {
                    setState(() {
                      _selectedAddressId = provider.addresses.last.id;
                    });
                  } else if (provider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.error!)),
                    );
                  }
                }
              },
              child: const Text('Добавить', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _placeOrder() async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    String addressText = '';

    if (addressProvider.addresses.isNotEmpty && _selectedAddressId != null) {
      try {
        final selectedAddressObj = addressProvider.addresses.firstWhere((a) => a.id == _selectedAddressId);
        addressText = selectedAddressObj.addressText;
      } catch (_) {
        addressText = addressProvider.addresses.first.addressText;
      }
    } else {
      addressText = _manualAddressController.text.trim();
    }

    if (addressText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, выберите или введите адрес доставки')));
      return;
    }

    if (_paymentMethod == 'card' || (_paymentMethod != 'cash' && !Provider.of<PaymentProvider>(context, listen: false).cards.any((c) => c.id == _paymentMethod))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, выберите способ оплаты или добавьте карту')));
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final items = cartProvider.items.map((e) => {
      'productId': e.product.id,
      'quantity': e.quantity,
    }).toList();

    try {
      await orderProvider.createOrder(null, addressText, items);
      
      if (mounted) {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        for (var item in cartProvider.items) {
          productProvider.decreaseStockLocally(item.product.id, item.quantity);
        }
        productProvider.fetchProducts();
      }

      cartProvider.clearCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заказ успешно оформлен!')));
        Navigator.popUntil(context, ModalRoute.withName('/main'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Адрес доставки', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            if (addressProvider.isLoading && addressProvider.addresses.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (addressProvider.addresses.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Сохраненных адресов не найдено. Пожалуйста, введите адрес вручную:', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  CustomTextField(
                    label: 'Адрес',
                    controller: _manualAddressController,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ],
              )
            else
              Card(
                color: AppColors.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    children: [
                      ...addressProvider.addresses.map((address) => RadioListTile<String>(
                            title: Text(address.addressText),
                            subtitle: address.isDefault ? const Text('Основной адрес', style: TextStyle(color: AppColors.primary, fontSize: 12)) : null,
                            value: address.id,
                            groupValue: _selectedAddressId,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _selectedAddressId = value;
                              });
                            },
                          )),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.add, color: AppColors.primary),
                        title: const Text('Добавить новый адрес', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                        onTap: _showAddAddressDialog,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Text('Способ оплаты', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                return Card(
                  child: Column(
                    children: [
                      ...paymentProvider.cards.map((card) {
                        final last4 = card.number.length >= 4 
                            ? card.number.substring(card.number.length - 4) 
                            : card.number;
                        
                        String brand = 'Карта';
                        if (card.number.startsWith('4')) brand = 'Visa';
                        else if (card.number.startsWith('5')) brand = 'MasterCard';
                        else if (card.number.startsWith('2')) brand = 'Мир';

                        return RadioListTile<String>(
                          title: Text('$brand, оканчивающаяся на $last4'),
                          subtitle: Text(card.cardHolderName),
                          value: card.id,
                          groupValue: _paymentMethod,
                          activeColor: AppColors.primary,
                          onChanged: (value) => setState(() => _paymentMethod = value!),
                        );
                      }),
                      ListTile(
                        leading: const Icon(Icons.add, color: AppColors.primary),
                        title: const Text('Добавить новую карту', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddCardScreen()),
                          ).then((_) {
                            paymentProvider.loadCards().then((_) {
                              if (paymentProvider.cards.isNotEmpty) {
                                setState(() {
                                  _paymentMethod = paymentProvider.cards.last.id;
                                });
                              }
                            });
                          });
                        },
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        title: const Text('Оплата при получении'),
                        value: 'cash',
                        groupValue: _paymentMethod,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _paymentMethod = value!),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Состав заказа', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    ...cartProvider.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Text('${item.quantity}x ${item.product.name}'),
                              const Spacer(),
                              Text('${((item.product.discountPrice ?? item.product.price) * item.quantity).toStringAsFixed(2)} ₽'),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      children: [
                        const Text('Стоимость товаров'),
                        const Spacer(),
                        Text('${cartProvider.totalAmount.toStringAsFixed(2)} ₽'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Доставка'),
                        const Spacer(),
                        Text('${cartProvider.deliveryFee.toStringAsFixed(2)} ₽'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Text('Итого', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('${(cartProvider.totalAmount + cartProvider.deliveryFee).toStringAsFixed(2)} ₽', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(
            text: 'Оформить заказ',
            onPressed: orderProvider.isLoading ? null : _placeOrder,
            isLoading: orderProvider.isLoading,
          ),
        ),
      ),
    );
  }
}
