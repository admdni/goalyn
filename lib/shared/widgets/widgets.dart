import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_palette.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = imageUrl != null && imageUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
            errorWidget: (context, url, error) => errorWidget ?? _buildError(),
          )
        : errorWidget ?? _buildError();

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}

/// Editorial team monogram — a square with a thin border and serif initials.
/// Renders text only; the [logoUrl] is intentionally ignored to preserve
/// a magazine-style typography-first aesthetic.
class TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final String name;
  final double size;
  final bool enableHero;
  final String? heroTag;

  const TeamLogo({
    super.key,
    required this.logoUrl,
    required this.name,
    this.size = 40,
    this.enableHero = false,
    this.heroTag,
  });

  String get _initials {
    if (name.isEmpty) return '—';
    final cleaned = name
        .replaceAll(RegExp(r'^(FC|AC|AS|SC|SV|VfL|VfB|RB|UEFA)\s+'), '')
        .replaceAll(RegExp(r'\s+(FC|AC|CF|SC|FK|JK|BK)$'), '')
        .trim();
    final words =
        cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '—';
    if (words.length == 1) {
      return words.first.length >= 2
          ? words.first.substring(0, 2).toUpperCase()
          : words.first.toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.paper,
        border: Border.all(color: p.line, width: 0.6),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Georgia',
          fontSize: size * 0.42,
          height: 1.0,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: p.textPrimary,
        ),
      ),
    );

    if (enableHero && heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: logo,
      );
    }
    return logo;
  }
}

/// Compact editorial badge for a league or competition (text-only).
class LeagueBadge extends StatelessWidget {
  final String name;
  final double size;

  const LeagueBadge({super.key, required this.name, this.size = 56});

  String get _ticker {
    final cleaned = name
        .replaceAll(RegExp(r'^UEFA\s+'), '')
        .replaceAll(RegExp(r'\s+League$'), 'L')
        .trim();
    final words =
        cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '—';
    if (words.length == 1) {
      final w = words.first;
      return w.length >= 3 ? w.substring(0, 3).toUpperCase() : w.toUpperCase();
    }
    return (words[0][0] +
            words[1][0] +
            (words.length > 2 ? words[2][0] : ''))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.paper,
        border: Border.all(color: p.line, width: 0.6),
      ),
      alignment: Alignment.center,
      child: Text(
        _ticker,
        style: TextStyle(
          fontFamily: 'Georgia',
          fontStyle: FontStyle.italic,
          fontSize: size * 0.30,
          height: 1.0,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: p.accent,
        ),
      ),
    );
  }
}

class LiveBadge extends StatelessWidget {
  final bool isLive;
  final String? elapsed;

  const LiveBadge({
    super.key,
    this.isLive = true,
    this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLive) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.live.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(size: 6),
          const SizedBox(width: 4),
          Text(
            elapsed != null ? "$elapsed'" : 'LIVE',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.live,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final double size;

  const _PulsingDot({required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: AppColors.live.withOpacity(0.5 + _controller.value * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isLive;
  final String? elapsed;

  const StatusBadge({
    super.key,
    required this.status,
    this.isLive = false,
    this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (isLive) {
      backgroundColor = AppColors.live.withOpacity(0.15);
      textColor = AppColors.live;
    } else if (status == 'FT' || status == 'Full Time') {
      backgroundColor = AppColors.info.withOpacity(0.15);
      textColor = AppColors.info;
    } else if (status == 'HT' || status == 'Half Time') {
      backgroundColor = AppColors.warning.withOpacity(0.15);
      textColor = AppColors.warning;
    } else {
      backgroundColor = AppColors.surface;
      textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLive
          ? LiveBadge(isLive: true, elapsed: elapsed)
          : Text(
              status,
              style: AppTypography.labelSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action!,
                    style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Border? border;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.card : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
