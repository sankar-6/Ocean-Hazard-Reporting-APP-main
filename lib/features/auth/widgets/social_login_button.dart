import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: Colors.grey[300]!,
        ),
        backgroundColor: backgroundColor ?? Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: textColor ?? Colors.grey[700],
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
