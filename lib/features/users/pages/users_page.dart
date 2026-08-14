import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/widgets/page_error.dart';
import 'package:mediahub/features/users/controllers/users_controller.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/users_list.dart';

/// Page dedicated to the management and search of users.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final UsersController controller;
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  bool _showScrollToTop = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller = UsersController()..fetchUsers();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return PageError(
            title: 'Impossibile caricare gli utenti',
            onRetry: controller.fetchUsers,
          );
        }

        final List<User> users = controller.users;
        final List<User> filteredUsers = _filterUsers(users);
        final bool hasActiveSearch = _searchQuery.trim().isNotEmpty;

        return Container(
          color: appBackgroundColor,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Utenti',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Gestisci utenti, ruoli e attivita',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _UsersSearchBar(
                  controller: _searchController,
                  query: _searchQuery,
                  resultCount: filteredUsers.length,
                  totalCount: users.length,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _UsersStats(users: users),
                          const SizedBox(height: 24),
                          if (filteredUsers.isEmpty && hasActiveSearch)
                            _UsersSearchEmptyState(query: _searchQuery)
                          else
                            UsersList(users: filteredUsers),
                        ],
                      ),
                    ),
                    _buildScrollToTopButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    controller.dispose();
    super.dispose();
  }

  Widget _buildScrollToTopButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 12,
      child: AnimatedOpacity(
        duration: AnimationConfig.hoverDuration,
        opacity: _showScrollToTop ? 1 : 0,
        child: IgnorePointer(
          ignoring: !_showScrollToTop,
          child: Center(
            child: SizedBox(
              width: 34,
              height: 34,
              child: FloatingActionButton(
                heroTag: null,
                mini: true,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: AnimationConfig.scrollToTopDuration,
                    curve: Curves.easeOutCubic,
                  );
                },
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,
                child: const Icon(Icons.keyboard_arrow_up, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Filters users by name and email using the current query.
  List<User> _filterUsers(List<User> users) {
    if (_searchQuery.trim().isEmpty) {
      return users;
    }

    final String query = _searchQuery.toLowerCase().trim();

    return users.where((User user) {
      final String fullName = '${user.name} ${user.lastName}'.toLowerCase();
      final String email = user.email.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  /// Shows or hides the floating button for returning to the top.
  void _handleScroll() {
    final bool shouldShow = _scrollController.hasClients
        ? _scrollController.offset > 120
        : false;

    if (_showScrollToTop == shouldShow) {
      return;
    }

    setState(() => _showScrollToTop = shouldShow);
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }
}

/// Search box for users with live result count and clear action.
class _UsersSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _UsersSearchBar({
    required this.controller,
    required this.query,
    required this.resultCount,
    required this.totalCount,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < 700;
    final bool hasQuery = query.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 680),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: isMobile ? 34 : 38,
            height: isMobile ? 34 : 38,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Cerca per nome o email...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$resultCount/$totalCount',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          if (hasQuery) ...<Widget>[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Pulisci ricerca',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: const Color(0xFF6B7280),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state for a search without results.
class _UsersSearchEmptyState extends StatelessWidget {
  final String query;

  const _UsersSearchEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nessun utente trovato',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Nessun risultato per "$query"',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

/// Summary cards for total, active and inactive users.
class _UsersStats extends StatelessWidget {
  final List<User> users;

  const _UsersStats({required this.users});

  @override
  Widget build(BuildContext context) {
    final int total = users.length;
    final int active = users.where((User user) => user.isActive).length;
    final int inactive = total - active;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 900 ? 3 : 1;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.2,
          ),
          children: <Widget>[
            _StatCard(
              title: 'Utenti totali',
              value: '$total',
              accent: const Color(0xFF4F46E5),
              icon: Icons.people_alt_rounded,
            ),
            _StatCard(
              title: 'Attivi',
              value: '$active',
              accent: const Color(0xFF14B8A6),
              icon: Icons.bolt_rounded,
            ),
            _StatCard(
              title: 'Inattivi',
              value: '$inactive',
              accent: const Color(0xFFEF4444),
              icon: Icons.pause_circle_rounded,
            ),
          ],
        );
      },
    );
  }
}

/// A metric card shown in the users summary row.
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 22,
            offset: Offset(0, 10),
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
