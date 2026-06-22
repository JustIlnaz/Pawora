import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Помощь и поддержка')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Часто задаваемые вопросы', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                const ExpansionTile(
                  title: Text('Как оформить заказ?'),
                  children: [Padding(padding: EdgeInsets.all(16), child: Text('Чтобы оформить заказ, добавьте товары в корзину, перейдите к оформлению, укажите адрес доставки и выберите способ оплаты.'))],
                ),
                const ExpansionTile(
                  title: Text('Как отследить заказ?'),
                  children: [Padding(padding: EdgeInsets.all(16), child: Text('Вы можете отслеживать статус заказа в разделе «Мои заказы» в вашем профиле.'))],
                ),
                const ExpansionTile(
                  title: Text('Условия возврата?'),
                  children: [Padding(padding: EdgeInsets.all(16), child: Text('Мы принимаем возврат неиспользованных товаров в оригинальной упаковке в течение 14 дней с момента доставки.'))],
                ),
                const ExpansionTile(
                  title: Text('Контактная информация?'),
                  children: [Padding(padding: EdgeInsets.all(16), child: Text('Эл. почта: support@pawora.com\nТелефон: 1-800-PAWORA'))],
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: PrimaryButton(
                text: 'Связаться с поддержкой',
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
