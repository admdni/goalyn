import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

/// Unified editorial screen scaffold — a tight masthead, an ink rule, and a
/// content slot. Every secondary screen in the app uses this so the visual
/// language stays consistent.
class ScreenScaffold extends StatelessWidget {
  final String? eyebrow;
  final String? title;
  final List<Widget> actions;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;
  final Widget? bottom;
  final bool useListView;

  const ScreenScaffold({
    super.key,
    this.eyebrow,
    this.title,
    this.actions = const [],
    required this.child,
    this.showBack = true,
    this.onBack,
    this.padding = EdgeInsets.zero,
    this.bottom,
    this.useListView = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildMasthead(context),
            Expanded(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }

  Widget _buildMasthead(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: p.background,
        border: Border(
          bottom: BorderSide(color: p.line, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(Icons.arrow_back, color: p.textPrimary, size: 18),
                ),
              if (showBack) const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null)
                      Text(
                        eyebrow!.toUpperCase(),
                        style: AppType.eyebrow(
                          size: 9,
                          color: p.textTertiary,
                          letterSpacing: 1.4,
                        ),
                      ),
                    if (title != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.sans(
                          size: 17,
                          color: p.textPrimary,
                          weight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...actions,
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A subtle icon-only action button, used in screen scaffolds.
class IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;

  const IconAction({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: Icon(icon, color: color ?? p.textPrimary, size: size),
    );
  }
}
