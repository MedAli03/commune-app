import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum HomeActionCardVariant {
  primary,
  secondary,
}

class HomeActionCard extends StatefulWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.variant,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final HomeActionCardVariant variant;
  final VoidCallback onTap;

  @override
  State<HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<HomeActionCard> {
  bool _isPressed = false;

  bool get _isPrimary => widget.variant == HomeActionCardVariant.primary;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        _isPrimary ? AppPalette.accentGreen : AppPalette.surfaceAlt;
    final textColor = _isPrimary ? Colors.white : AppPalette.textPrimary;
    final subtitleColor = _isPrimary ? Colors.white70 : AppPalette.textMuted;
    final borderColor =
        _isPrimary ? Colors.transparent : AppPalette.outlineSoft;

    return Material(
      color: Colors.transparent,
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (isHighlighted) {
            setState(() {
              _isPressed = isHighlighted;
            });
          },
          borderRadius: AppRadii.lg,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppRadii.lg,
              border: Border.all(color: borderColor),
              boxShadow: _isPrimary
                  ? const [
                      BoxShadow(
                        color: Color(0x4530BF3B),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isPrimary
                        ? Colors.white.withValues(alpha: 0.24)
                        : AppPalette.accentGreen.withValues(alpha: 0.16),
                    borderRadius: AppRadii.md,
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isPrimary ? Colors.white : AppPalette.accentGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _isPrimary ? Colors.white70 : AppPalette.textMuted,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
