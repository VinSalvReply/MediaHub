import 'package:flutter/material.dart';
import 'package:mediahub/features/users/controllers/users_controller.dart';
import 'package:mediahub/features/users/widgets/users_list.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final UsersController controller;

  @override
  void initState() {
    super.initState();
    controller = UsersController()..fetchUsers();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(child: Text(controller.error!));
        }

        final users = controller.users;

        return Container(
          color: const Color(0xFFF5F7FB),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Users',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Manage users, roles and activity',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _TopActionButton(icon: Icons.search_rounded, onTap: () {}),
                    const SizedBox(width: 10),
                    _TopActionButton(
                      icon: Icons.filter_alt_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _UsersStats(users: users),
                const SizedBox(height: 24),
                UsersList(users: users),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopActionButton({required this.icon, required this.onTap});

  @override
  State<_TopActionButton> createState() => _TopActionButtonState();
}

class _TopActionButtonState extends State<_TopActionButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hovered ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hovered
              ? const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x12000000),
                  ),
                ]
              : [],
        ),
        child: IconButton(
          onPressed: widget.onTap,
          icon: Icon(widget.icon, size: 20),
        ),
      ),
    );
  }
}

class _UsersStats extends StatelessWidget {
  final List<dynamic> users;

  const _UsersStats({required this.users});

  @override
  Widget build(BuildContext context) {
    final total = users.length;
    final active = users.where((u) => u.isActive == true).length;
    final inactive = total - active;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 3 : 1;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.2,
          ),
          children: [
            _StatCard(
              title: 'Total users',
              value: '$total',
              accent: const Color(0xFF4F46E5),
              icon: Icons.people_alt_rounded,
            ),
            _StatCard(
              title: 'Active',
              value: '$active',
              accent: const Color(0xFF14B8A6),
              icon: Icons.bolt_rounded,
            ),
            _StatCard(
              title: 'Inactive',
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
        boxShadow: const [
          BoxShadow(
            blurRadius: 22,
            offset: Offset(0, 10),
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        children: [
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
              children: [
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
