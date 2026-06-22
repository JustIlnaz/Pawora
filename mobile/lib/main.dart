import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/user_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/address_provider.dart';
import 'providers/payment_provider.dart';

// Theme
import 'theme/app_theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/search_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/help_screen.dart';
import 'screens/add_pet_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_products_screen.dart';
import 'screens/admin_orders_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/address_management_screen.dart';

void main() {
  runApp(const PaworaApp());
}

class PaworaApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const PaworaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PaymentProvider>(
          create: (_) => PaymentProvider(),
          update: (_, auth, payment) => payment!..updateUser(auth.user?.id),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Pawora',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainScreen(),
          '/search': (context) => const SearchScreen(),
          '/product': (context) => const ProductDetailScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
          '/map': (context) => const MapScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/payment_methods': (context) => const PaymentMethodsScreen(),
          '/help': (context) => const HelpScreen(),
          '/add_pet': (context) => const AddPetScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
          '/admin/products': (context) => const AdminProductsScreen(),
          '/admin/products/add': (context) => const AddProductScreen(),
          '/admin/orders': (context) => const AdminOrdersScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/addresses': (context) => const AddressManagementScreen(),
        },
      ),
    );
  }
}
