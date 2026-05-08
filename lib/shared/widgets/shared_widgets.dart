import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final String teamName;
  final double size;
  final Color? backgroundColor;

  const TeamLogo({
    super.key,
    required this.logoUrl,
    required this.teamName,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceDark.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final initials = teamName.isEmpty
        ? '?'
        : teamName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.label1.copyWith(
          fontSize: size * 0.35,
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class LiveIndicator extends StatelessWidget {
  final bool isPulsing;
  final double size;

  const LiveIndicator({
    super.key,
    this.isPulsing = true,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPulsing) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.liveRed,
          shape: BoxShape.circle,
        ),
      );
    }

    return _PulsingDot(size: size);
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
      duration: const Duration(milliseconds: 1200),
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
          width: widget.size + (_controller.value * 4),
          height: widget.size + (_controller.value * 4),
          decoration: BoxDecoration(
            color: AppColors.liveRed.withOpacity(0.4 + (_controller.value * 0.6)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: AppColors.liveRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
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
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionText!,
                style: AppTextStyles.label2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
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

class MatchStatusBadge extends StatelessWidget {
  final String status;
  final bool isLive;
  final String? elapsed;

  const MatchStatusBadge({
    super.key,
    required this.status,
    this.isLive = false,
    this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLive
            ? AppColors.liveRed.withOpacity(0.15)
            : status == 'FT'
                ? AppColors.finishedBlue.withOpacity(0.15)
                : AppColors.scheduledGray.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            const LiveIndicator(size: 6),
            const SizedBox(width: 4),
          ],
          Text(
            isLive ? '${elapsed ?? ''}\'' : status,
            style: AppTextStyles.caption.copyWith(
              color: isLive
                  ? AppColors.liveRed
                  : status == 'FT'
                      ? AppColors.finishedBlue
                      : AppColors.scheduledGray,
              fontWeight: FontWeight.w700,
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
  final Gradient? gradient;
  final double borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.gradient,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.cardGradientDark,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding!,
            child: child,
          ),
        ),
      ),
    );
  }
}