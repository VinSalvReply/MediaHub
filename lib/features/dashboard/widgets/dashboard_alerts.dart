import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

/// Displays the alert chips returned by the dashboard API.
class DashboardAlerts extends StatelessWidget {
  final List<DashboardAlert> alerts;

  const DashboardAlerts({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: alerts
          .map((DashboardAlert alert) => _AlertChip(alert: alert))
          .toList(),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final DashboardAlert alert;

  const _AlertChip({required this.alert});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (alert.type) {
      'warning' => warningColor,
      'info' => primaryColor,
      'error' => dangerColor,
      _ => DashboardColors.neutral,
    };
    final IconData icon = switch (alert.type) {
      'warning' => Icons.warning_rounded,
      'info' => Icons.info_rounded,
      'error' => Icons.error_rounded,
      _ => Icons.notifications_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            alert.message,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
