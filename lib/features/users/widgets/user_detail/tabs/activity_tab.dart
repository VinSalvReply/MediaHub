import 'package:flutter/material.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/features/users/models/user_activity.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

class ActivityTab extends StatelessWidget {
  final UserDetailData data;

  const ActivityTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.activities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final a = data.activities[i];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 220 + i * 40),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) {
            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 12),
                child: child,
              ),
            );
          },
          child: _ActivityTile(activity: a),
        );
      },
    );
  }
}

class _ActivityTile extends StatefulWidget {
  final UserActivity activity;

  const _ActivityTile({required this.activity});

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: hover ? const Color(0xFFF8FAFC) : const Color(0xFFFDFDFE),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hover
              ? const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x10000000),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF4F46E5).withValues(alpha: 0.10),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 18,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                a.description,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatDate(a.date),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
