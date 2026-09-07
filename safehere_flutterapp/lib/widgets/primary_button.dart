import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: loading ? null : onPressed, child: child)
          : ElevatedButton(onPressed: loading ? null : onPressed, child: child),
    );
  }
}
