import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

class EventsTab extends StatelessWidget {
  final UserDetailData data;

  const EventsTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.events.length,
      itemBuilder: (context, i) {
        final e = data.events[i];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EventCard(event: e),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            defaultColorLight!.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            formatDate(event.date),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
