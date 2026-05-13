import 'package:flutter/material.dart';
import 'package:mediahub/features/users/models/user.dart';

class UserDetailModal extends StatelessWidget {
  final User user;

  const UserDetailModal({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 900,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _Header(user: user),
            const SizedBox(height: 20),
            Expanded(child: _UserTabs(user: user)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final User user;

  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          child: Text('${user.name[0]}${user.lastName[0]}'),
        ),

        const SizedBox(height: 10),

        Text(
          '${user.name} ${user.lastName}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        Text(user.email, style: TextStyle(color: Colors.grey)),

        const SizedBox(height: 8),

        Chip(label: Text(user.role)),
      ],
    );
  }
}

class _UserTabs extends StatelessWidget {
  final User user;

  const _UserTabs({required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Activity"),
              Tab(text: "Events"),
              Tab(text: "Content"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // _OverviewTab(user: user),
                // _ActivityTab(user: user),
                // _EventsTab(user: user),
                // _ContentTab(user: user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
