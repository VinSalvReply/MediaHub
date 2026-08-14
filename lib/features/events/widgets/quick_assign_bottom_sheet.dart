import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/events/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

/// Searchable bottom sheet used to assign or unassign an event user.
class QuickAssignBottomSheet extends StatefulWidget {
  final Event event;
  final List<User> users;
  final ValueChanged<int?> onAssign;

  const QuickAssignBottomSheet({
    super.key,
    required this.event,
    required this.users,
    required this.onAssign,
  });

  @override
  State<QuickAssignBottomSheet> createState() => _QuickAssignBottomSheetState();
}

class _QuickAssignBottomSheetState extends State<QuickAssignBottomSheet> {
  late final TextEditingController _searchController;
  List<User> _filteredUsers = <User>[];
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredUsers = widget.users;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderColor),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: eventSheetShadowColor,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: eventSheetDividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              _SheetHeader(event: widget.event),
              _SearchField(
                controller: _searchController,
                onChanged: _filterUsers,
              ),
              Expanded(child: _buildUserList(scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(ScrollController scrollController) {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Nessun utente disponibile'
              : 'Nessun utente trovato',
          style: const TextStyle(color: textMutedColor, fontSize: 14),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.metrics.axis == Axis.vertical) {
              _updateScrollToTopVisibility(notification.metrics);
            }
            return false;
          },
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filteredUsers.length,
            itemBuilder: (BuildContext context, int index) {
              final User user = _filteredUsers[index];
              return _UserAssignmentTile(
                user: user,
                isAssigned: widget.event.userId == user.id,
                onAssign: widget.onAssign,
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: AnimatedOpacity(
            duration: AnimationConfig.hoverDuration,
            opacity: _showScrollToTop ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_showScrollToTop,
              child: Center(
                child: FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  onPressed: () => scrollController.animateTo(
                    0,
                    duration: AnimationConfig.scrollToTopDuration,
                    curve: Curves.easeOutCubic,
                  ),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.keyboard_arrow_up, size: 18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _filterUsers(String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    setState(() {
      _filteredUsers = normalizedQuery.isEmpty
          ? widget.users
          : widget.users.where((User user) {
              final String name = '${user.name} ${user.lastName}'.toLowerCase();
              return name.contains(normalizedQuery) ||
                  user.email.toLowerCase().contains(normalizedQuery);
            }).toList();
    });
  }

  void _updateScrollToTopVisibility(ScrollMetrics metrics) {
    final bool shouldShow = metrics.pixels > 120;
    if (_showScrollToTop != shouldShow) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _SheetHeader extends StatelessWidget {
  final Event event;

  const _SheetHeader({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: eventSheetDividerColor)),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Assegna utente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: eventSheetTitleColor,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Chiudi',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cerca per nome o email...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: textMutedColor,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: eventInputSurfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _UserAssignmentTile extends StatelessWidget {
  final User user;
  final bool isAssigned;
  final ValueChanged<int?> onAssign;

  const _UserAssignmentTile({
    required this.user,
    required this.isAssigned,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => onAssign(isAssigned ? null : user.id),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isAssigned
                ? primaryColor.withValues(alpha: 0.08)
                : eventInputSurfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAssigned
                  ? primaryColor.withValues(alpha: 0.3)
                  : eventAssignedBorderColor,
              width: isAssigned ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.person_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${user.name} ${user.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textMutedColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAssigned)
                IconButton(
                  tooltip: 'Rimuovi assegnazione',
                  icon: const Icon(Icons.close_rounded, color: dangerColor),
                  onPressed: () => onAssign(null),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
