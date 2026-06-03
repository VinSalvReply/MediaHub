import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediahub/features/users/models/content_item.dart';

String _contentStatusLabel(String status) {
  switch (status) {
    case 'published':
      return 'Pubblicato';
    case 'archived':
      return 'Archiviato';
    case 'draft':
    default:
      return 'Bozza';
  }
}

class ContentListTile extends StatelessWidget {
  final ContentItem content;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContentListTile({
    super.key,
    required this.content,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: Row(
        children: [
          _TypeIcon(type: content.type),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Creato il ${dateFmt.format(content.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                if (content.type == 'post' &&
                    (content.postBody?.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: 8),
                  Text(
                    content.postBody!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Badge(
                      label: _contentStatusLabel(content.status),
                      background: const Color(
                        0xFF4F46E5,
                      ).withValues(alpha: 0.12),
                      foreground: const Color(0xFF4F46E5),
                    ),
                    if (content.userId != null)
                      _Badge(
                        label: 'Utente #${content.userId}',
                        background: const Color(
                          0xFF14B8A6,
                        ).withValues(alpha: 0.12),
                        foreground: const Color(0xFF0F766E),
                      ),
                    if (content.eventId != null)
                      _Badge(
                        label: 'Evento #${content.eventId}',
                        background: const Color(
                          0xFFF59E0B,
                        ).withValues(alpha: 0.15),
                        foreground: const Color(0xFFB45309),
                      ),
                    if (content.mediaUrls.isNotEmpty)
                      _Badge(
                        label: content.mediaUrls.length == 1
                            ? '1 media'
                            : '${content.mediaUrls.length} media',
                        background: const Color(
                          0xFF0EA5E9,
                        ).withValues(alpha: 0.15),
                        foreground: const Color(0xFF0369A1),
                      ),
                    if (content.tags.isNotEmpty)
                      _Badge(
                        label: '#${content.tags.take(2).join(' #')}',
                        background: const Color(
                          0xFF10B981,
                        ).withValues(alpha: 0.15),
                        foreground: const Color(0xFF047857),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Modifica',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Elimina',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final String type;

  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      'video' => (Icons.smart_display_rounded, const Color(0xFFEF4444)),
      'image' => (Icons.image_rounded, const Color(0xFF22C55E)),
      _ => (Icons.article_rounded, const Color(0xFF4F46E5)),
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
