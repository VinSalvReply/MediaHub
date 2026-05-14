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
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final a = data.activities[i];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 250 + i * 50),
          tween: Tween(begin: 0, end: 1),
          builder: (context, v, child) {
            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 10),
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

class _ActivityTile extends StatelessWidget {
  final UserActivity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withValues(alpha: 0.03),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(activity.description)),
          Text(
            formatDate(activity.date),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
