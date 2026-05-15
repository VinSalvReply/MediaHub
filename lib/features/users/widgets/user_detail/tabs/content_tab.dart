import 'package:flutter/material.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

class ContentTab extends StatelessWidget {
  final UserDetailData data;

  const ContentTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 5 / 2,
      ),
      itemCount: data.contents.length,
      itemBuilder: (context, i) {
        final c = data.contents[i];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 220 + i * 40),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) {
            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 10),
                child: child,
              ),
            );
          },
          child: _ContentTile(content: c),
        );
      },
    );
  }
}

class _ContentTile extends StatefulWidget {
  final ContentItem content;

  const _ContentTile({required this.content});

  @override
  State<_ContentTile> createState() => _ContentTileState();
}

class _ContentTileState extends State<_ContentTile> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, hover ? -3.0 : 0.0)
          ..scale(hover ? 1.03 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hover
              ? const [
                  BoxShadow(
                    blurRadius: 22,
                    offset: Offset(0, 10),
                    color: Color(0x14000000),
                  ),
                ]
              : const [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, 6),
                    color: Color(0x08000000),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Color(0xFFEC4899),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.content.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
