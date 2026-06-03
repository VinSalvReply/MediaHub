import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mediahub/features/contents/controllers/contents_controller.dart';
import 'package:mediahub/features/contents/widgets/content_form_dialog.dart';
import 'package:mediahub/features/contents/widgets/content_list_tile.dart';
import 'package:mediahub/features/users/models/content_item.dart';

const _bgColor = Color(0xFFF5F7FB);
const _borderColor = Color(0xFFE7EAF0);
const _textMuted = Color(0xFF6B7280);

enum ContentSortMode { nameAsc, nameDesc, dateAsc, dateDesc }

enum _SplitLane { all, assigned, unassigned }

class ContentsPage extends StatefulWidget {
  const ContentsPage({super.key});

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {
  late final ContentsController controller;
  final GlobalKey<_ContentAssignmentSidebarState> _assignmentSidebarKey =
      GlobalKey<_ContentAssignmentSidebarState>();
  bool _isDraggingContent = false;
  bool _dragFromEventDropZone = false;
  ContentSortMode _sortMode = ContentSortMode.dateDesc;
  bool _splitAssigned = false;
  bool _previousSplitAssigned = false;
  int _sortTick = 0;
  Map<int, int> _previousAllContentIndexes = const {};
  Map<int, int> _previousAssignedContentIndexes = const {};
  Map<int, int> _previousUnassignedContentIndexes = const {};

  void _startContentDragFromGlobalList() {
    if (_isDraggingContent && !_dragFromEventDropZone) return;
    setState(() {
      _isDraggingContent = true;
      _dragFromEventDropZone = false;
    });
  }

  void _startContentDragFromEventDropZone() {
    if (_isDraggingContent && _dragFromEventDropZone) return;
    setState(() {
      _isDraggingContent = true;
      _dragFromEventDropZone = true;
    });
  }

  void _endContentDrag() {
    if (!_isDraggingContent && !_dragFromEventDropZone) {
      return;
    }
    setState(() {
      _isDraggingContent = false;
      _dragFromEventDropZone = false;
    });
  }

  void _setSortMode(ContentSortMode? mode) {
    if (mode == null || mode == _sortMode) return;
    final before = _sortedContentsFor(_sortMode);
    final beforeAssigned = before
        .where((item) => item.eventId != null)
        .toList();
    final beforeUnassigned = before
        .where((item) => item.eventId == null)
        .toList();
    setState(() {
      // A pure sort change should not trigger split lane transition animation.
      _previousSplitAssigned = _splitAssigned;
      _previousAllContentIndexes = _indexByContentId(before);
      _previousAssignedContentIndexes = _indexByContentId(beforeAssigned);
      _previousUnassignedContentIndexes = _indexByContentId(beforeUnassigned);
      _sortMode = mode;
      _sortTick++;
    });
  }

  List<ContentItem> _sortedContentsFor(ContentSortMode mode) {
    return [...controller.contents]..sort((a, b) {
      switch (mode) {
        case ContentSortMode.nameAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case ContentSortMode.nameDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case ContentSortMode.dateAsc:
          return a.createdAt.compareTo(b.createdAt);
        case ContentSortMode.dateDesc:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
  }

  Map<int, int> _indexByContentId(List<ContentItem> items) {
    return {for (var i = 0; i < items.length; i++) items[i].id: i};
  }

  void _setSplitAssigned(bool value) {
    if (_splitAssigned == value) return;
    setState(() {
      _previousSplitAssigned = _splitAssigned;
      _splitAssigned = value;
      _sortTick++;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = ContentsController()..init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<ContentFormResult>(
      context: context,
      builder: (_) => const ContentFormDialog(),
    );
    if (result == null) return;
    await controller.addContent(
      title: result.title,
      type: result.type,
      status: result.status,
      mediaUrls: result.mediaUrls,
      postBody: result.postBody,
      callToActionLabel: result.callToActionLabel,
      callToActionUrl: result.callToActionUrl,
      tags: result.tags,
    );
    _toast('Contenuto creato');
  }

  Future<void> _openEditDialog(ContentItem item) async {
    final result = await showDialog<ContentFormResult>(
      context: context,
      builder: (_) => ContentFormDialog(initial: item),
    );
    if (result == null) return;
    await controller.editContent(
      original: item,
      title: result.title,
      type: result.type,
      status: result.status,
      mediaUrls: result.mediaUrls,
      postBody: result.postBody,
      callToActionLabel: result.callToActionLabel,
      callToActionUrl: result.callToActionUrl,
      tags: result.tags,
    );
    _toast('Contenuto aggiornato');
  }

  Future<void> _assignContent(ContentItem item, int? eventId) async {
    if (eventId == null) return;
    await controller.assignContentToEvent(item, eventId);
    if (!mounted) return;
    _toast('Contenuto collegato all\'evento');
  }

  Future<void> _unassignContent(ContentItem item) async {
    await controller.assignContentToEvent(item, null);
    if (!mounted) return;
    _toast('Contenuto disassegnato');
  }

  Future<void> _confirmDelete(ContentItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare contenuto?'),
        content: Text('"${item.title}" verrà rimosso definitivamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await controller.removeContent(item);
    _toast('Contenuto eliminato');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          color: _bgColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  onCreate: _openCreateDialog,
                  onRefresh: controller.loadContents,
                ),
                const SizedBox(height: 24),
                _ContentsWorkspace(
                  controller: controller,
                  onAssign: _assignContent,
                  onUnassign: _unassignContent,
                  canUnassignFromCurrentDrag: _dragFromEventDropZone,
                  sortMode: _sortMode,
                  onSortChanged: _setSortMode,
                  splitAssigned: _splitAssigned,
                  previousSplitAssigned: _previousSplitAssigned,
                  onSplitChanged: _setSplitAssigned,
                  sortTick: _sortTick,
                  previousAllContentIndexes: _previousAllContentIndexes,
                  previousAssignedContentIndexes:
                      _previousAssignedContentIndexes,
                  previousUnassignedContentIndexes:
                      _previousUnassignedContentIndexes,
                  isDragging: _isDraggingContent,
                  onGlobalListDragStart: _startContentDragFromGlobalList,
                  onSidebarDragStart: _startContentDragFromEventDropZone,
                  onDragEnd: _endContentDrag,
                  onDragCursorMove: (position) {
                    _assignmentSidebarKey.currentState?.autoScrollAt(position);
                  },
                  assignmentSidebarKey: _assignmentSidebarKey,
                  onCreate: _openCreateDialog,
                  onEdit: _openEditDialog,
                  onDelete: _confirmDelete,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onRefresh;

  const _Header({required this.onCreate, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contenuti',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Crea e modifica contenuti globali',
                style: TextStyle(color: _textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Aggiorna',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Nuovo contenuto',
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: Color(0x0A000000),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ContentsWorkspace extends StatelessWidget {
  final ContentsController controller;
  final Future<void> Function(ContentItem item, int? eventId) onAssign;
  final Future<void> Function(ContentItem item) onUnassign;
  final bool canUnassignFromCurrentDrag;
  final ContentSortMode sortMode;
  final ValueChanged<ContentSortMode?> onSortChanged;
  final bool splitAssigned;
  final bool previousSplitAssigned;
  final ValueChanged<bool> onSplitChanged;
  final int sortTick;
  final Map<int, int> previousAllContentIndexes;
  final Map<int, int> previousAssignedContentIndexes;
  final Map<int, int> previousUnassignedContentIndexes;
  final bool isDragging;
  final VoidCallback onGlobalListDragStart;
  final VoidCallback onSidebarDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<Offset> onDragCursorMove;
  final GlobalKey<_ContentAssignmentSidebarState> assignmentSidebarKey;
  final VoidCallback onCreate;
  final ValueChanged<ContentItem> onEdit;
  final ValueChanged<ContentItem> onDelete;

  const _ContentsWorkspace({
    required this.controller,
    required this.onAssign,
    required this.onUnassign,
    required this.canUnassignFromCurrentDrag,
    required this.sortMode,
    required this.onSortChanged,
    required this.splitAssigned,
    required this.previousSplitAssigned,
    required this.onSplitChanged,
    required this.sortTick,
    required this.previousAllContentIndexes,
    required this.previousAssignedContentIndexes,
    required this.previousUnassignedContentIndexes,
    required this.isDragging,
    required this.onGlobalListDragStart,
    required this.onSidebarDragStart,
    required this.onDragEnd,
    required this.onDragCursorMove,
    required this.assignmentSidebarKey,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1120;
        if (compact) {
          return Column(
            children: [
              _ContentsBody(
                controller: controller,
                sortMode: sortMode,
                onSortChanged: onSortChanged,
                splitAssigned: splitAssigned,
                previousSplitAssigned: previousSplitAssigned,
                onSplitChanged: onSplitChanged,
                sortTick: sortTick,
                previousAllContentIndexes: previousAllContentIndexes,
                previousAssignedContentIndexes: previousAssignedContentIndexes,
                previousUnassignedContentIndexes:
                    previousUnassignedContentIndexes,
                onGlobalListDragStart: onGlobalListDragStart,
                onDragEnd: onDragEnd,
                onDragCursorMove: onDragCursorMove,
                onCreate: onCreate,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
              const SizedBox(height: 16),
              _ContentAssignmentSidebar(
                key: assignmentSidebarKey,
                controller: controller,
                onAssign: onAssign,
                onUnassign: onUnassign,
                canUnassignFromCurrentDrag: canUnassignFromCurrentDrag,
                onSidebarDragStart: onSidebarDragStart,
                onDragEnd: onDragEnd,
                onDragCursorMove: onDragCursorMove,
                dragActive: isDragging,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _ContentsBody(
                controller: controller,
                sortMode: sortMode,
                onSortChanged: onSortChanged,
                splitAssigned: splitAssigned,
                previousSplitAssigned: previousSplitAssigned,
                onSplitChanged: onSplitChanged,
                sortTick: sortTick,
                previousAllContentIndexes: previousAllContentIndexes,
                previousAssignedContentIndexes: previousAssignedContentIndexes,
                previousUnassignedContentIndexes:
                    previousUnassignedContentIndexes,
                onGlobalListDragStart: onGlobalListDragStart,
                onDragEnd: onDragEnd,
                onDragCursorMove: onDragCursorMove,
                onCreate: onCreate,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _ContentAssignmentSidebar(
                key: assignmentSidebarKey,
                controller: controller,
                onAssign: onAssign,
                onUnassign: onUnassign,
                canUnassignFromCurrentDrag: canUnassignFromCurrentDrag,
                onSidebarDragStart: onSidebarDragStart,
                onDragEnd: onDragEnd,
                onDragCursorMove: onDragCursorMove,
                dragActive: isDragging,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ContentAssignmentSidebar extends StatefulWidget {
  final ContentsController controller;
  final Future<void> Function(ContentItem item, int? eventId) onAssign;
  final Future<void> Function(ContentItem item) onUnassign;
  final bool canUnassignFromCurrentDrag;
  final VoidCallback onSidebarDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<Offset> onDragCursorMove;
  final bool dragActive;

  const _ContentAssignmentSidebar({
    super.key,
    required this.controller,
    required this.onAssign,
    required this.onUnassign,
    required this.canUnassignFromCurrentDrag,
    required this.onSidebarDragStart,
    required this.onDragEnd,
    required this.onDragCursorMove,
    required this.dragActive,
  });

  @override
  State<_ContentAssignmentSidebar> createState() =>
      _ContentAssignmentSidebarState();
}

class _ContentAssignmentSidebarState extends State<_ContentAssignmentSidebar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScrollOnEdge(PointerHoverEvent event) {
    autoScrollAt(event.position);
  }

  void autoScrollAt(Offset globalPosition) {
    if (!widget.dragActive) return;
    if (!_scrollController.hasClients) return;
    final box = context.findRenderObject();
    if (box is! RenderBox) return;
    final local = box.globalToLocal(globalPosition);
    if (local.dx < 0 || local.dx > box.size.width) return;
    final h = box.size.height;
    const edge = 56.0;
    double delta = 0;
    if (local.dy < edge) delta = -16;
    if (local.dy > h - edge) delta = 16;
    if (delta == 0) return;
    final max = _scrollController.position.maxScrollExtent;
    final next = (_scrollController.offset + delta).clamp(0.0, max);
    _scrollController.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller.isLoadingMeta) {
      return const _Card(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return MouseRegion(
      onHover: _autoScrollOnEdge,
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 420, maxHeight: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Eventi (area di rilascio)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trascina le card contenuto da sinistra verso un evento.',
                style: TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ...controller.events.map((event) {
                      final items = controller.contents
                          .where((item) => item.eventId == event.id)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ContentDropZone(
                          title: event.title,
                          subtitle: 'Evento #${event.id}',
                          icon: Icons.event_rounded,
                          items: items,
                          onDragStart: widget.onSidebarDragStart,
                          onDragEnd: widget.onDragEnd,
                          onDragCursorMove: widget.onDragCursorMove,
                          onAccept: (item) => widget.onAssign(item, event.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _ScopedContentUnassignZone(
                enabled: widget.canUnassignFromCurrentDrag,
                onAccept: widget.onUnassign,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentDropZone extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<ContentItem> items;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<Offset> onDragCursorMove;
  final ValueChanged<ContentItem> onAccept;

  const _ContentDropZone({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.items,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragCursorMove,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ContentItem>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFE7EAF0),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              if (items.isEmpty)
                const Text(
                  'Trascina qui un contenuto',
                  style: TextStyle(fontSize: 12, color: _textMuted),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map(
                        (item) => Draggable<ContentItem>(
                          data: item,
                          onDragStarted: onDragStart,
                          onDragUpdate: (details) =>
                              onDragCursorMove(details.globalPosition),
                          onDragEnd: (_) => onDragEnd(),
                          onDragCompleted: onDragEnd,
                          onDraggableCanceled: (_, _) => onDragEnd(),
                          feedback: Material(
                            color: Colors.transparent,
                            child: _ContentChip(item: item, dragging: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.45,
                            child: _ContentChip(item: item),
                          ),
                          child: _ContentChip(item: item),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ScopedContentUnassignZone extends StatelessWidget {
  final bool enabled;
  final Future<void> Function(ContentItem item) onAccept;

  const _ScopedContentUnassignZone({
    required this.enabled,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ContentItem>(
      onWillAcceptWithDetails: (_) => enabled,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, _) {
        final active = enabled && candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFEDD5) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? const Color(0xFFEA580C) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.link_off_rounded,
                size: 18,
                color: enabled
                    ? const Color(0xFF9A3412)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  enabled
                      ? 'Rilascia qui per disassegnare contenuto'
                      : 'Disassegna disponibile solo dal drag interno eventi',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: enabled
                        ? const Color(0xFF7C2D12)
                        : const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContentChip extends StatelessWidget {
  final ContentItem item;
  final bool dragging;

  const _ContentChip({required this.item, this.dragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dragging ? const Color(0xFFF59E0B) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Text(
        item.title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: dragging ? Colors.white : const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _ContentsBody extends StatelessWidget {
  final ContentsController controller;
  final ContentSortMode sortMode;
  final ValueChanged<ContentSortMode?> onSortChanged;
  final bool splitAssigned;
  final bool previousSplitAssigned;
  final ValueChanged<bool> onSplitChanged;
  final int sortTick;
  final Map<int, int> previousAllContentIndexes;
  final Map<int, int> previousAssignedContentIndexes;
  final Map<int, int> previousUnassignedContentIndexes;
  final VoidCallback onGlobalListDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<Offset> onDragCursorMove;
  final VoidCallback onCreate;
  final ValueChanged<ContentItem> onEdit;
  final ValueChanged<ContentItem> onDelete;

  const _ContentsBody({
    required this.controller,
    required this.sortMode,
    required this.onSortChanged,
    required this.splitAssigned,
    required this.previousSplitAssigned,
    required this.onSplitChanged,
    required this.sortTick,
    required this.previousAllContentIndexes,
    required this.previousAssignedContentIndexes,
    required this.previousUnassignedContentIndexes,
    required this.onGlobalListDragStart,
    required this.onDragEnd,
    required this.onDragCursorMove,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingMeta || controller.isLoadingContents) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.error != null && controller.contents.isEmpty) {
      return _Card(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 32),
            const SizedBox(height: 12),
            Text(controller.error!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.loadContents,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    if (controller.contents.isEmpty) {
      return _Card(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.layers_clear_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nessun contenuto trovato',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Crea il primo contenuto per iniziare',
              style: TextStyle(color: _textMuted),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuovo contenuto'),
            ),
          ],
        ),
      );
    }

    final sorted = [...controller.contents]
      ..sort((a, b) {
        switch (sortMode) {
          case ContentSortMode.nameAsc:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case ContentSortMode.nameDesc:
            return b.title.toLowerCase().compareTo(a.title.toLowerCase());
          case ContentSortMode.dateAsc:
            return a.createdAt.compareTo(b.createdAt);
          case ContentSortMode.dateDesc:
            return b.createdAt.compareTo(a.createdAt);
        }
      });

    final assigned = sorted.where((item) => item.eventId != null).toList();
    final unassigned = sorted.where((item) => item.eventId == null).toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Contenuti',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<ContentSortMode>(
                  initialValue: sortMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ContentSortMode.nameAsc,
                      child: Text('Nome A-Z'),
                    ),
                    DropdownMenuItem(
                      value: ContentSortMode.nameDesc,
                      child: Text('Nome Z-A'),
                    ),
                    DropdownMenuItem(
                      value: ContentSortMode.dateAsc,
                      child: Text('Data crescente'),
                    ),
                    DropdownMenuItem(
                      value: ContentSortMode.dateDesc,
                      child: Text('Data decrescente'),
                    ),
                  ],
                  onChanged: onSortChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dividi vista: assegnati a sinistra, non assegnati a destra',
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ),
              Switch.adaptive(value: splitAssigned, onChanged: onSplitChanged),
            ],
          ),
          const SizedBox(height: 6),
          if (!splitAssigned)
            Column(
              children: _buildContentCards(
                sorted,
                previousAllContentIndexes,
                lane: _SplitLane.all,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final compactSplit = constraints.maxWidth < 900;
                if (compactSplit) {
                  return Column(
                    children: [
                      _SplitSection(title: 'Assegnati', count: assigned.length),
                      ..._buildContentCards(
                        assigned,
                        previousAssignedContentIndexes,
                        lane: _SplitLane.assigned,
                      ),
                      const SizedBox(height: 10),
                      _SplitSection(
                        title: 'Non assegnati',
                        count: unassigned.length,
                      ),
                      ..._buildContentCards(
                        unassigned,
                        previousUnassignedContentIndexes,
                        lane: _SplitLane.unassigned,
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _SplitSection(
                            title: 'Assegnati',
                            count: assigned.length,
                          ),
                          ..._buildContentCards(
                            assigned,
                            previousAssignedContentIndexes,
                            lane: _SplitLane.assigned,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _SplitSection(
                            title: 'Non assegnati',
                            count: unassigned.length,
                          ),
                          ..._buildContentCards(
                            unassigned,
                            previousUnassignedContentIndexes,
                            lane: _SplitLane.unassigned,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          if (controller.isMutating)
            const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildContentCards(
    List<ContentItem> source,
    Map<int, int> previousIndexes, {
    required _SplitLane lane,
  }) {
    const itemStep = 122.0;
    return [
      for (var i = 0; i < source.length; i++)
        Padding(
          key: ValueKey('content-${source[i].id}-$sortTick'),
          padding: const EdgeInsets.only(bottom: 12),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 700 + (i * 35).clamp(0, 260)),
            tween: Tween(begin: 1, end: 0),
            curve: Curves.easeInOutCubicEmphasized,
            builder: (context, value, child) {
              final previousIndex = previousIndexes[source[i].id];
              final fromOffsetY = previousIndex == null
                  ? 0.0
                  : (previousIndex - i) * itemStep;
              final toggledSplit = splitAssigned != previousSplitAssigned;
              var fromOffsetX = 0.0;
              if (toggledSplit) {
                final isAssigned = source[i].eventId != null;
                if (splitAssigned && lane == _SplitLane.unassigned) {
                  fromOffsetX = -220;
                }
                if (!splitAssigned && lane == _SplitLane.all && !isAssigned) {
                  fromOffsetX = 220;
                }
              }
              return Transform.translate(
                offset: Offset(fromOffsetX * value, fromOffsetY * value),
                child: child,
              );
            },
            child: Draggable<ContentItem>(
              data: source[i],
              onDragStarted: onGlobalListDragStart,
              onDragUpdate: (details) =>
                  onDragCursorMove(details.globalPosition),
              onDragEnd: (_) => onDragEnd(),
              onDragCompleted: onDragEnd,
              onDraggableCanceled: (_, _) => onDragEnd(),
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 480,
                  child: ContentListTile(
                    content: source[i],
                    onEdit: () {},
                    onDelete: () {},
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.45,
                child: ContentListTile(
                  content: source[i],
                  onEdit: () => onEdit(source[i]),
                  onDelete: () => onDelete(source[i]),
                ),
              ),
              child: ContentListTile(
                content: source[i],
                onEdit: () => onEdit(source[i]),
                onDelete: () => onDelete(source[i]),
              ),
            ),
          ),
        ),
    ];
  }
}

class _SplitSection extends StatelessWidget {
  final String title;
  final int count;

  const _SplitSection({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count', style: const TextStyle(color: _textMuted)),
        ],
      ),
    );
  }
}
