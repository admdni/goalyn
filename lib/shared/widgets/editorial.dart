import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

/// Tiny tracked uppercase label — used as a section eyebrow.
class Eyebrow extends StatelessWidget {
  final String label;
  final Color? color;
  final double size;

  const Eyebrow(this.label, {super.key, this.color, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      label.toUpperCase(),
      style: AppType.eyebrow(
        size: size,
        color: color ?? p.textTertiary,
      ),
    );
  }
}

/// A horizontal hairline rule. Optionally inset.
class HairLine extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double thickness;

  const HairLine({
    super.key,
    this.height = 1,
    this.thickness = 0.5,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        height: thickness,
        color: color ?? context.palette.line,
      ),
    );
  }
}

/// Editorial section header: thin eyebrow + horizontal rule on the right.
class SectionRule extends StatelessWidget {
  final String label;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const SectionRule({
    super.key,
    required this.label,
    this.color,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 12),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Eyebrow(label, color: color ?? p.textPrimary),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 0.5, color: p.line)),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Display-serif headline. Default italic for editorial flavour.
class DisplayText extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final FontStyle style;
  final FontWeight weight;
  final TextAlign align;
  final int? maxLines;

  const DisplayText(
    this.text, {
    super.key,
    this.size = 36,
    this.color,
    this.style = FontStyle.normal,
    this.weight = FontWeight.w400,
    this.align = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      style: AppType.display(
        size: size,
        color: color ?? context.palette.textPrimary,
        style: style,
        weight: weight,
      ),
    );
  }
}

/// Italic editorial deck — short subhead under a headline.
class DeckText extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const DeckText(this.text, {super.key, this.color, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text,
      style: AppType.serif(
        size: size,
        color: color ?? p.textSecondary,
        style: FontStyle.italic,
        height: 1.4,
      ),
    );
  }
}

/// Big editorial figure (statistic) with a label.
class FigureBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final double valueSize;
  final CrossAxisAlignment alignment;

  const FigureBlock({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.valueSize = 44,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppType.mono(
            size: valueSize,
            color: valueColor ?? p.textPrimary,
            weight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Eyebrow(label, color: p.textTertiary, size: 9),
      ],
    );
  }
}

/// Refined editorial chip — square with hairline border.
class InkChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool filled;

  const InkChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? c : Colors.transparent,
        border: Border.all(color: c, width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: filled ? p.textInverse : c),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppType.eyebrow(
              size: 9,
              color: filled ? p.textInverse : c,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Backwards-compatible aliases for older widget names. Kept so screens that
// haven't been migrated yet still compile after the editorial refresh.
// ---------------------------------------------------------------------------

class SectionKicker extends StatelessWidget {
  final String label;
  final String? issue;
  final Color? color;
  final bool showRule;
  final EdgeInsetsGeometry padding;

  const SectionKicker({
    super.key,
    required this.label,
    this.issue,
    this.color,
    this.showRule = true,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 8),
  });

  @override
  Widget build(BuildContext context) {
    return SectionRule(
      label: label,
      color: color,
      padding: padding,
    );
  }
}

class EditorialHeadline extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;

  const EditorialHeadline(
    this.text, {
    super.key,
    this.fontSize = 30,
    this.color,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return DisplayText(
      text,
      size: fontSize,
      color: color,
      align: textAlign,
      style: FontStyle.italic,
    );
  }
}

class EditorialDeck extends StatelessWidget {
  final String text;
  final Color? color;

  const EditorialDeck(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) => DeckText(text, color: color);
}

class EditorialFigure extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final double valueSize;
  final CrossAxisAlignment alignment;

  const EditorialFigure({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.valueSize = 44,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return FigureBlock(
      value: value,
      label: label,
      valueColor: color,
      valueSize: valueSize,
      alignment: alignment,
    );
  }
}

class EditorialDivider extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Color? color;
  const EditorialDivider({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.color,
  });

  @override
  Widget build(BuildContext context) => HairLine(padding: padding, color: color);
}

class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const TagChip({super.key, required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) =>
      InkChip(label: label, color: color, icon: icon);
}

/// A small live pulse dot indicator.
class LivePulse extends StatefulWidget {
  final Color color;
  final double size;
  const LivePulse({super.key, required this.color, this.size = 6});

  @override
  State<LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color
              .withValues(alpha: 0.45 + _c.value * 0.55),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
