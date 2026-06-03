import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/routes/app_router.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

class EventsTab extends StatelessWidget {
  final UserDetailData data;

  const EventsTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.events.isEmpty) {
      return Center(
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7EAF0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_busy_rounded,
                size: 46,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nessun evento associato',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vai alla sezione eventi per crearne o associarne qualcuno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).maybePop();
                  context.go(AppRoutes.events);
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Apri sezione eventi'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final e = data.events[i];
        final linked = e.contents;

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
          child: _EventCard(event: e, linkedContents: linked),
        );
      },
    );
  }
}

class _EventCard extends StatefulWidget {
  final Event event;
  final List<ContentItem> linkedContents;

  const _EventCard({required this.event, required this.linkedContents});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final linked = widget.linkedContents;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: hover ? const Color(0xFFFCFCFD) : Colors.white,
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hover
              ? const [
                  BoxShadow(
                    blurRadius: 14,
                    offset: Offset(0, 6),
                    color: Color(0x0E000000),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.event_rounded,
                    color: Color(0xFF14B8A6),
                  ),
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _ContentCountBadge(count: linked.length),
              ],
            ),
            const SizedBox(height: 10),
            if (linked.isEmpty)
              const Text(
                'Nessun contenuto associato a questo evento',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: linked
                    .take(4)
                    .map((item) => _ContentPill(title: item.title))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContentCountBadge extends StatelessWidget {
  final int count;

  const _ContentCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count contenuti',
        style: const TextStyle(
          color: Color(0xFF4F46E5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ContentPill extends StatelessWidget {
  final String title;

  const _ContentPill({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFFEC4899).withValues(alpha: 0.10),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFBE185D),
        ),
      ),
    );
  }
}
