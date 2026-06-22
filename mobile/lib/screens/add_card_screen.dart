import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment_card.dart';
import '../providers/payment_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isDefault = false;

  bool _luhnCheck(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    if (cardNumber.isEmpty) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      final newCard = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        number: _numberController.text.replaceAll(' ', ''),
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        cardHolderName: _nameController.text.toUpperCase(),
        isDefault: _isDefault,
      );
      provider.addCard(newCard).then((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Карта успешно добавлена')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавление карты')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Номер карты',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите номер карты';
                  final digits = value.replaceAll(' ', '');
                  if (digits.length < 16) return 'Неверная длина номера';
                  if (!_luhnCheck(digits)) return 'Недействительный номер карты';
                  return null;
                },
                onChanged: (value) {
                  // Basic formatting
                  var text = value.replaceAll(' ', '');
                  var formatted = '';
                  for (int i = 0; i < text.length; i++) {
                    if (i > 0 && i % 4 == 0) formatted += ' ';
                    formatted += text[i];
                  }
                  if (formatted != value) {
                    _numberController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Срок действия',
                        hintText: 'MM/YY',
                      ),
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Введите срок';
                        if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
                          return 'Формат MM/YY';
                        }
                        
                        // Check if it's in the future
                        try {
                          final parts = value.split('/');
                          final month = int.parse(parts[0]);
                          final year = 2000 + int.parse(parts[1]);
                          final now = DateTime.now();
                          final cardDate = DateTime(year, month + 1, 0); // Last day of month
                          if (cardDate.isBefore(now)) return 'Срок истек';
                        } catch (e) {
                          return 'Неверная дата';
                        }
                        
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length == 2 && !_expiryController.text.contains('/')) {
                          _expiryController.text = '$value/';
                          _expiryController.selection = TextSelection.collapsed(offset: 3);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Введите CVV';
                        if (value.length < 3) return '3 цифры';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя владельца',
                  hintText: 'IVAN IVANOV',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите имя владельца';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('Сделать картой по умолчанию'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: 'Сохранить',
                onPressed: _saveCard,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
