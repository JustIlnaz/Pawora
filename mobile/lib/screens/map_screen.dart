import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shop_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Магазины рядом')),
      body: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(height: 16),
                Text('Для карты требуется API-ключ', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: provider.shops.length,
              itemBuilder: (context, index) {
                return ShopCard(shop: provider.shops[index], onTap: () {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
