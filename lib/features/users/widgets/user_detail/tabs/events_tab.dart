import 'package:flutter/material.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

class EventsTab extends StatelessWidget {
  final UserDetailData data;

  const EventsTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final e = data.events[i];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 220 + i * 50),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) {
            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 14),
                child: child,
              ),
            );
          },
          child: _EventCard(event: e),
        );
      },
    );
  }
}

class _EventCard extends StatefulWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: hover
                ? [
                    const Color(0xFF4F46E5).withValues(alpha: 0.10),
                    Colors.white,
                  ]
                : [Colors.white, const Color(0xFFF8FAFC)],
          ),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hover
              ? const [
                  BoxShadow(
                    blurRadius: 22,
                    offset: Offset(0, 10),
                    color: Color(0x14000000),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.event_rounded, color: Color(0xFF14B8A6)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(e.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
