import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surfaceLight,
            AppColors.surface,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class MatchCardShimmer extends StatelessWidget {
  final bool isCompact;

  const MatchCardShimmer({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          if (!isCompact) ...[
            Row(
              children: [
                Container(width: 60, height: 12, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6))),
                const Spacer(),
                Container(width: 40, height: 16, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8))),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle)),
                const SizedBox(height: 8),
                Container(width: 60, height: 10, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(5))),
              ]),
              Container(width: 50, height: 24, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8))),
              Column(children: [
                Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle)),
                const SizedBox(height: 8),
                Container(width: 60, height: 10, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(5))),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class NewsCardShimmer extends StatelessWidget {
  const NewsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 8),
                Container(height: 12, width: 150, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}