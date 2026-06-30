import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final bool showNotification;

  const CustomAppBar({super.key, this.titleText, this.showNotification = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: titleText != null,
      title: titleText != null 
          ? Text(titleText!)
          : Text(
              'PAWORA',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
      actions: [
        if (showNotification)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
