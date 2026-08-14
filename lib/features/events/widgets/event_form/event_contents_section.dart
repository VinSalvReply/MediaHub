import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/contents/models/content_item.dart';

/// Editor section that lists, adds, edits, and removes event contents.
class EventContentsSection extends StatelessWidget {
  final List<ContentItem> contents;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  const EventContentsSection({
    super.key,
    required this.contents,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 640;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: dashboardSubtleSurfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(compact: compact, onAdd: onAdd),
          const SizedBox(height: 6),
          const Text(
            'Ogni evento puo avere piu contenuti di natura diversa, con uno o piu media.',
            style: TextStyle(color: textMutedColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (contents.isEmpty)
            const Text(
              'Nessun contenuto inserito per questo evento.',
              style: TextStyle(color: textMutedColor),
            )
          else
            Column(
              children: <Widget>[
                for (int index = 0; index < contents.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EventContentRow(
                      content: contents[index],
                      onEdit: () => onEdit(index),
                      onDelete: () => onDelete(index),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final bool compact;
  final VoidCallback onAdd;

  const _SectionHeader({required this.compact, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final Widget title = const Text(
      'Contenuti dell\'evento',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
    final Widget addButton = FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Aggiungi contenuto'),
    );

    return compact
        ? Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SizedBox(width: double.infinity, child: title),
              addButton,
            ],
          )
        : Row(
            children: <Widget>[
              Expanded(child: title),
              addButton,
            ],
          );
  }
}

/// Compact content row with responsive actions.
class EventContentRow extends StatelessWidget {
  final ContentItem content;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventContentRow({
    super.key,
    required this.content,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 460;
    final int mediaCount = content.mediaUrls.length;
    final Widget leading = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: eventDropActiveSurfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_iconForType(content.type), color: primaryColor),
    );
    final Widget details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          content.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${_typeLabel(content.type)} - ${mediaCount == 1 ? '1 media' : '$mediaCount media'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: textMutedColor),
        ),
      ],
    );
    final Widget actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          tooltip: 'Modifica contenuto',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded),
        ),
        IconButton(
          tooltip: 'Rimuovi contenuto',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
          color: dangerColor,
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    leading,
                    const SizedBox(width: 12),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            )
          : Row(
              children: <Widget>[
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: details,
                  ),
                ),
                actions,
              ],
            ),
    );
  }
}

IconData _iconForType(String type) => switch (type) {
  'video' => Icons.smart_display_rounded,
  'image' => Icons.image_rounded,
  _ => Icons.article_rounded,
};

String _typeLabel(String type) => switch (type) {
  'image' => 'Immagine',
  'video' => 'Video',
  _ => 'Post',
};
