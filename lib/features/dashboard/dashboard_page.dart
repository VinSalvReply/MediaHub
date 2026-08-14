import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/core/widgets/page_error.dart';
import 'package:mediahub/features/dashboard/controllers/dashboard_controller.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';
import 'package:mediahub/features/dashboard/widgets/dashboard_alerts.dart';
import 'package:mediahub/features/dashboard/widgets/dashboard_metrics.dart';
import 'package:mediahub/features/dashboard/widgets/dashboard_panels.dart';
import 'package:mediahub/features/dashboard/widgets/dashboard_quick_actions.dart';
import 'package:mediahub/features/dashboard/widgets/dashboard_skeleton.dart';
import 'package:mediahub/features/dashboard/widgets/dashboard_trend.dart';

/// Dashboard entry point: owns loading state and composes feature widgets.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _fadeIn;
  late final DashboardController _dashboardController;

  @override
  void initState() {
    super.initState();
    _dashboardController = DashboardController()..loadDashboard();
    _introController = AnimationController(
      vsync: this,
      duration: AnimationConfig.dashboardIntroDuration,
      animationBehavior: AnimationBehavior.preserve,
    );
    _fadeIn = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _introController.forward();
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: AnimatedBuilder(
            animation: _dashboardController,
            builder: (BuildContext context, _) {
              if (_dashboardController.errorMessage != null &&
                  _dashboardController.data == null) {
                return PageError(
                  title: 'Impossibile caricare la dashboard',
                  onRetry: _reload,
                );
              }
              if (_dashboardController.isLoading &&
                  _dashboardController.data == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: DashboardSkeleton(),
                );
              }

              final DashboardData? data = _dashboardController.data;
              if (data == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: DashboardSkeleton(),
                );
              }
              return _DashboardContent(
                data: data,
                onRefresh: _reload,
                isRefreshing: _dashboardController.isLoading,
              );
            },
          ),
        ),
      ),
    );
  }

  void _reload() {
    _dashboardController.loadDashboard();
  }
}

/// Responsive dashboard composition. Individual sections live in widgets/.
class _DashboardContent extends StatelessWidget {
  final DashboardData data;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const _DashboardContent({
    required this.data,
    required this.onRefresh,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= ResponsiveBreakpoints.tablet;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DashboardHeader(
                  onRefresh: onRefresh,
                  isRefreshing: isRefreshing,
                ),
                const SizedBox(height: 24),
                DashboardAlerts(alerts: data.alerts),
                const SizedBox(height: 24),
                DashboardMetricsGrid(metrics: data.metrics),
                const SizedBox(height: 24),
                wide ? _WideSections(data: data) : _CompactSections(data: data),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Trend operativo',
                  subtitle:
                      'Andamento di utenti attivi e contenuti creati nel tempo',
                  child: DashboardTrendPanel(trend: data.trend),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Azioni rapide',
                  subtitle:
                      'Le operazioni più frequenti per tenere vivo il calendario',
                  child: const DashboardQuickActions(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WideSections extends StatelessWidget {
  final DashboardData data;

  const _WideSections({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 876,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: _SectionCard(
              title: 'Attività recenti',
              subtitle: 'Eventi e contenuti che stanno muovendo la pipeline',
              expandChild: true,
              child: DashboardActivityFeed(items: data.activities),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _SectionCard(
                    title: 'Copertura operativa',
                    subtitle:
                        'Indicatori rapidi sulla qualità del piano editoriale',
                    child: DashboardInsightsPanel(items: data.insights),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Eventi da attenzionare',
                    subtitle:
                        'Priorità operative tra contenuti mancanti, draft e media',
                    child: DashboardFocusEventsPanel(events: data.focusEvents),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactSections extends StatelessWidget {
  final DashboardData data;

  const _CompactSections({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SectionCard(
          title: 'Attività recenti',
          subtitle: 'Eventi e contenuti che stanno muovendo la pipeline',
          child: DashboardActivityFeed(items: data.activities),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Copertura operativa',
          subtitle: 'Indicatori rapidi sulla qualità del piano editoriale',
          child: DashboardInsightsPanel(items: data.insights),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Eventi da attenzionare',
          subtitle: 'Priorità operative tra contenuti mancanti, draft e media',
          child: DashboardFocusEventsPanel(events: data.focusEvents),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const _DashboardHeader({required this.onRefresh, required this.isRefreshing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Dashboard MediaHub',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text(
                'Controllo operativo di eventi, contenuti e copertura media',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _HeaderAction(icon: Icons.search_rounded, onPressed: () {}),
        const SizedBox(width: 10),
        _HeaderAction(
          icon: Icons.refresh_rounded,
          onPressed: onRefresh,
          isLoading: isRefreshing,
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;

  const _HeaderAction({
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: icon == Icons.refresh_rounded ? 'Aggiorna' : 'Cerca',
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 20),
    );
  }
}

/// Common frame used by dashboard sections to keep spacing and borders uniform.
class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool expandChild;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.expandChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: textMutedColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}
