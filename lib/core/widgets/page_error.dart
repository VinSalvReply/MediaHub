import 'package:flutter/material.dart';

import 'package:mediahub/core/constants/color.dart';

/// Standard error state used across the app when a page cannot load its data.
class PageError extends StatelessWidget {
  const PageError({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Riprova',
    this.icon = Icons.error_rounded,
    this.iconColor = dangerColor,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final bool hasRetryAction = onRetry != null;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 42, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textMutedColor, fontSize: 14),
              ),
            ],
            if (hasRetryAction) ...<Widget>[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
