import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'add_card_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Способы оплаты')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.cards.isEmpty
                      ? const Center(child: Text('У вас пока нет сохраненных карт'))
                      : ListView.builder(
                          itemCount: provider.cards.length,
                          itemBuilder: (context, index) {
                            final card = provider.cards[index];
                            final last4 = card.number.length >= 4 
                                ? card.number.substring(card.number.length - 4) 
                                : card.number;
                            
                            String brand = 'Карта';
                            if (card.number.startsWith('4')) brand = 'Visa';
                            else if (card.number.startsWith('5')) brand = 'MasterCard';
                            else if (card.number.startsWith('2')) brand = 'Мир';

                            return Card(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: ListTile(
                                leading: const Icon(Icons.credit_card, color: AppColors.primary),
                                title: Text('$brand, оканчивающаяся на $last4'),
                                subtitle: Text(card.cardHolderName),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: card.id,
                                      groupValue: provider.cards.firstWhere((c) => c.isDefault, orElse: () => provider.cards.first).id,
                                      onChanged: (value) {
                                        if (value != null) provider.setDefaultCard(value);
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () => provider.removeCard(card.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: 'Добавить новую карту',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCardScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

