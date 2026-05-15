import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  final List<_DashboardMetric> _metrics = const [
    _DashboardMetric(
      title: 'Users',
      value: '128',
      delta: '+12%',
      icon: Icons.people_alt_rounded,
      accent: Color(0xFF4F46E5),
    ),
    _DashboardMetric(
      title: 'Active',
      value: '87',
      delta: '+6%',
      icon: Icons.bolt_rounded,
      accent: Color(0xFF14B8A6),
    ),
    _DashboardMetric(
      title: 'Events',
      value: '34',
      delta: '+3',
      icon: Icons.event_rounded,
      accent: Color(0xFFF59E0B),
    ),
    _DashboardMetric(
      title: 'Content',
      value: '241',
      delta: '+18',
      icon: Icons.layers_rounded,
      accent: Color(0xFFEC4899),
    ),
  ];

  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      title: 'Luca Rossi created a new event',
      subtitle: 'Live Streaming - 12 min ago',
      icon: Icons.add_circle_rounded,
      color: Color(0xFF4F46E5),
    ),
    _ActivityItem(
      title: 'Giulia Bianchi updated a content item',
      subtitle: 'Promo video - 28 min ago',
      icon: Icons.edit_rounded,
      color: Color(0xFF14B8A6),
    ),
    _ActivityItem(
      title: 'Marco Verdi logged in',
      subtitle: 'Desktop web - 43 min ago',
      icon: Icons.login_rounded,
      color: Color(0xFFF59E0B),
    ),
    _ActivityItem(
      title: 'Admin disabled a user profile',
      subtitle: 'Security action - 1 hour ago',
      icon: Icons.verified_user_rounded,
      color: Color(0xFFEF4444),
    ),
  ];

  final List<_InsightItem> _insights = const [
    _InsightItem(label: 'Active users', value: 0.74, color: Color(0xFF4F46E5)),
    _InsightItem(
      label: 'Event coverage',
      value: 0.52,
      color: Color(0xFF14B8A6),
    ),
    _InsightItem(
      label: 'Content growth',
      value: 0.88,
      color: Color(0xFFEC4899),
    ),
    _InsightItem(label: 'System health', value: 0.94, color: Color(0xFF22C55E)),
  ];

  final List<_QuickAction> _quickActions = const [
    _QuickAction(
      title: 'Create user',
      subtitle: 'Add a new operator or editor',
      icon: Icons.person_add_alt_1_rounded,
      color: Color(0xFF4F46E5),
    ),
    _QuickAction(
      title: 'Create event',
      subtitle: 'Schedule a new live session',
      icon: Icons.event_available_rounded,
      color: Color(0xFF14B8A6),
    ),
    _QuickAction(
      title: 'Upload content',
      subtitle: 'Push a new asset or campaign',
      icon: Icons.upload_rounded,
      color: Color(0xFFEC4899),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1200;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        title: 'MediaHub Dashboard',
                        subtitle: 'Operations overview and system insights',
                        onSearchTap: () {},
                        onRefreshTap: () {},
                      ),
                      const SizedBox(height: 24),
                      _MetricsGrid(metrics: _metrics),
                      const SizedBox(height: 24),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _SectionCard(
                                title: 'Recent activity',
                                subtitle: 'What is happening right now',
                                child: _ActivityFeed(items: _activities),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: _SectionCard(
                                title: 'Insights',
                                subtitle:
                                    'Derived from users, events and content',
                                child: _InsightsPanel(items: _insights),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _SectionCard(
                          title: 'Recent activity',
                          subtitle: 'What is happening right now',
                          child: _ActivityFeed(items: _activities),
                        ),
                        const SizedBox(height: 20),
                        _SectionCard(
                          title: 'Insights',
                          subtitle: 'Derived from users, events and content',
                          child: _InsightsPanel(items: _insights),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'Quick actions',
                        subtitle: 'Start from common operations',
                        child: _QuickActionsGrid(actions: _quickActions),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onSearchTap;
  final VoidCallback onRefreshTap;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onSearchTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _IconActionButton(icon: Icons.search_rounded, onTap: onSearchTap),
        const SizedBox(width: 10),
        _IconActionButton(icon: Icons.refresh_rounded, onTap: onRefreshTap),
      ],
    );
  }
}

class _IconActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({required this.icon, required this.onTap});

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hovered ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hovered
              ? const [
                  BoxShadow(
                    blurRadius: 20,
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

class _MetricsGrid extends StatelessWidget {
  final List<_DashboardMetric> metrics;

  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 900
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _MetricCard(metric: metric);
          },
        );
      },
    );
  }
}

class _MetricCard extends StatefulWidget {
  final _DashboardMetric metric;

  const _MetricCard({required this.metric});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()
          ..translateByDouble(0.0, hovered ? -4.0 : 0.0, 0.0, 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hovered
              ? const [
                  BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, 12),
                    color: Color(0x12000000),
                  ),
                ]
              : const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x08000000),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: metric.accent.withValues(alpha: 0.12),
                ),
                child: Icon(metric.icon, color: metric.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metric.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          metric.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          metric.delta,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: metric.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 10),
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  final List<_ActivityItem> items;

  const _ActivityFeed({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == items.length - 1 ? 0 : 12,
              ),
              child: _ActivityRow(item: entry.value),
            ),
          )
          .toList(),
    );
  }
}

class _ActivityRow extends StatefulWidget {
  final _ActivityItem item;

  const _ActivityRow({required this.item});

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hovered ? const Color(0xFFF8FAFC) : const Color(0xFFFDFDFE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7EAF0)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: item.color.withValues(alpha: 0.12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _InsightsPanel extends StatelessWidget {
  final List<_InsightItem> items;

  const _InsightsPanel({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _InsightBar(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _InsightBar extends StatelessWidget {
  final _InsightItem item;

  const _InsightBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '${(item.value * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: item.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: item.value,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_QuickAction> actions;

  const _QuickActionsGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 3.2,
          ),
          itemBuilder: (context, index) {
            return _QuickActionCard(action: actions[index]);
          },
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hovered
              ? action.color.withValues(alpha: 0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hovered
                ? action.color.withValues(alpha: 0.24)
                : const Color(0xFFE7EAF0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: action.color.withValues(alpha: 0.14),
              ),
              child: Icon(action.icon, color: action.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
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

class _DashboardMetric {
  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final Color accent;

  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
    required this.accent,
  });
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _InsightItem {
  final String label;
  final double value;
  final Color color;

  const _InsightItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
