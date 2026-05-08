import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/editorial.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: p.textPrimary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Eyebrow(title, color: p.textPrimary),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 0.5, color: p.line)),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: _buildContentWidgets(p),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContentWidgets(AppPalette p) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('•')) {
        // Bullet point
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: AppType.sans(size: 15, color: p.textSecondary),
                ),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: AppType.sans(
                      size: 15,
                      color: p.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (_isSectionHeading(line, lines)) {
        // Section heading
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.trim(),
              style: AppType.serif(
                size: 20,
                color: p.textPrimary,
                style: FontStyle.italic,
              ),
            ),
          ),
        );
      } else if (line.startsWith('Last updated:')) {
        // Date subtitle
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line.trim(),
              style: AppType.sans(
                size: 13,
                color: p.textTertiary,
              ),
            ),
          ),
        );
      } else {
        // Regular paragraph text
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line.trim(),
              style: AppType.sans(
                size: 15,
                color: p.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  /// A line is a section heading if it is short, has no trailing punctuation,
  /// and is not a bullet or the date line.
  bool _isSectionHeading(String line, List<String> allLines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('•')) return false;
    if (trimmed.startsWith('Last updated')) return false;
    if (trimmed.endsWith('.') || trimmed.endsWith(',')) return false;
    if (trimmed.length > 40) return false;
    // Must be followed by content (not another short heading)
    final idx = allLines.indexOf(line);
    if (idx < allLines.length - 1) {
      final next = allLines[idx + 1].trim();
      return next.isNotEmpty && next.length > 40 || next.startsWith('•') || next.startsWith('We ') || next.startsWith('Our ') || next.startsWith('You ') || next.startsWith('While') || next.startsWith('The ') || next.startsWith('Goalyn') || next.startsWith('Predictions') || next.startsWith('By ') || next.startsWith('For ');
    }
    return false;
  }
}
