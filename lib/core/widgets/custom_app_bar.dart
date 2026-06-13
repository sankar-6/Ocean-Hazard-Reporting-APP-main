import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => _handleBackNavigation(context),
            )
          : null,
    );
  }

  void _handleBackNavigation(BuildContext context) {
    // Check if we can pop the current route
    if (context.canPop()) {
      context.pop();
    } else {
      // If we can't pop, navigate to dashboard as fallback
      context.go('/dashboard');
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Specialized AppBars for different contexts
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const AuthAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showBackButton: showBackButton,
      onBackPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/login');
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const MainAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: actions,
      showBackButton: false, // Main screens don't show back button
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const DetailAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: actions,
      showBackButton: true,
      onBackPressed: onBackPressed,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
