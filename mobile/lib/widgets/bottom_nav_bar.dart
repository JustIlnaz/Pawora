import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
        BottomNavigationBarItem(
          icon: Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          label: 'Корзина',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ],
    );
  }
}
