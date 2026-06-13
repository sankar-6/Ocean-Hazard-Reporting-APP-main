import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget that provides adaptive back navigation behavior
/// Handles both Android predictive back gestures and traditional back button
class AdaptiveBackScope extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool canPop;
  final String? popRoute;

  const AdaptiveBackScope({
    super.key,
    required this.child,
    this.onBackPressed,
    this.canPop = true,
    this.popRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleBackNavigation(context);
        }
      },
      child: child,
    );
  }

  void _handleBackNavigation(BuildContext context) {
    if (onBackPressed != null) {
      onBackPressed!();
    } else if (popRoute != null) {
      context.go(popRoute!);
    } else if (context.canPop()) {
      context.pop();
    } else {
      // If can't pop, go to dashboard as fallback
      context.go('/dashboard');
    }
  }
}

/// Extension to easily wrap widgets with adaptive back navigation
extension AdaptiveBackExtension on Widget {
  Widget withAdaptiveBack({
    VoidCallback? onBackPressed,
    bool canPop = true,
    String? popRoute,
  }) {
    return AdaptiveBackScope(
      onBackPressed: onBackPressed,
      canPop: canPop,
      popRoute: popRoute,
      child: this,
    );
  }
}
