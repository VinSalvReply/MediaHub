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
        childAspectRatio: 1.2,
      ),
      itemCount: data.contents.length,
      itemBuilder: (context, i) {
        final c = data.contents[i];

        return _ContentTile(content: c);
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
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(hover ? 1.03 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withValues(alpha: 0.03),
          boxShadow: hover
              ? [const BoxShadow(blurRadius: 20, color: Colors.black12)]
              : [],
        ),
        child: Center(child: Text(widget.content.title)),
      ),
    );
  }
}
