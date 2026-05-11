import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_models.dart';

// ── Color Constants (updated to new palette) ─────────────────────────────────
// These are light-mode reference values for non-context-aware use cases only.
// In widgets, always prefer Theme.of(context).colorScheme.* instead.
class EthioColors {
  // Primary — Deep Teal
  static const Color primary = Color(0xFF1B6B93);
  static const Color primaryContainer = Color(0xFFD0EFFF);
  static const Color onPrimaryContainer = Color(0xFF003550);

  // Secondary — Warm Amber
  static const Color secondary = Color(0xFFE07B39);
  static const Color secondaryContainer = Color(0xFFFFE4CC);
  static const Color onSecondaryContainer = Color(0xFF4A2000);

  // Tertiary — Emerald
  static const Color tertiary = Color(0xFF2D8F6F);
  static const Color tertiaryContainer = Color(0xFFC8F5E3);
  static const Color onTertiaryContainer = Color(0xFF003828);

  // Surfaces
  static const Color background = Color(0xFFF4F8FB);
  static const Color surface = Color(0xFFECF3F8);
  static const Color surfaceContainer = Color(0xFFECF3F8);
  static const Color surfaceContainerHigh = Color(0xFFDDE8EF);
  static const Color surfaceContainerHighest = Color(0xFFDDE8EF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F7FA);

  // Text & UI
  static const Color ink = Color(0xFF111820);
  static const Color mutedInk = Color(0xFF5A7080);
  static const Color outline = Color(0xFF6A8FA4);
  static const Color error = Color(0xFFD42F2F);
}

// ── Spacing System ────────────────────────────────────────────────────────────
class EthioSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 32;
}

// ── Offline Chip ──────────────────────────────────────────────────────────────
class OfflineChip extends StatelessWidget {
  const OfflineChip({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: EthioSpacing.lg, vertical: EthioSpacing.sm),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 15, color: c),
          const SizedBox(width: EthioSpacing.sm),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: c,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: EthioSpacing.xs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: scheme.primary,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

// ── Category Pill ─────────────────────────────────────────────────────────────
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = selected ? scheme.primary : scheme.surfaceContainerLowest;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    final borderColor =
        selected ? Colors.transparent : scheme.outline.withValues(alpha: 0.2);
    return ActionChip(
      onPressed: onTap,
      side: BorderSide(color: borderColor),
      backgroundColor: background,
      labelPadding: const EdgeInsets.symmetric(horizontal: EthioSpacing.sm),
      avatar: Icon(icon, size: 18, color: foreground),
      label: Text(label,
          style: TextStyle(
              color: foreground, fontWeight: FontWeight.w700)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(
          horizontal: EthioSpacing.md, vertical: EthioSpacing.sm + 2),
    );
  }
}

// ── Destination Art ───────────────────────────────────────────────────────────
class DestinationArt extends StatelessWidget {
  const DestinationArt({
    super.key,
    required this.destination,
    this.showBadge = true,
    this.compact = false,
  });

  final Destination destination;
  final bool showBadge;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 24 : 30),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            destination.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: destination.accent.withValues(alpha: 0.15),
              child: Icon(Icons.image_not_supported_rounded,
                  color: destination.accent.withValues(alpha: 0.6)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
          Positioned(
            left: compact ? 14 : 18,
            right: compact ? 14 : 18,
            top: compact ? 12 : 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showBadge)
                  _ArtBadge(
                    icon: Icons.location_on,
                    label: destination.region,
                  )
                else
                  const SizedBox.shrink(),
                Container(
                  width: compact ? 34 : 42,
                  height: compact ? 34 : 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bookmark_border_rounded,
                      color: destination.accent,
                      size: compact ? 18 : 22),
                ),
              ],
            ),
          ),
          Positioned(
            left: compact ? 18 : 22,
            right: compact ? 18 : 22,
            bottom: compact ? 16 : 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 22 : 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: EthioSpacing.sm - 2),
                Text(
                  destination.summary,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: compact ? 13 : 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtBadge extends StatelessWidget {
  const _ArtBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: EthioSpacing.md, vertical: EthioSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: EthioSpacing.sm),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Destination Card ──────────────────────────────────────────────────────────
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
    this.compact = false,
  });

  final Destination destination;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: compact ? 260 : 360,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: scheme.onSurface.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DestinationArt(destination: destination, compact: compact),
        ),
      ),
    );
  }
}

// ── Stat Tile ─────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.all(EthioSpacing.lg),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c),
          const SizedBox(height: EthioSpacing.lg + 2),
          Text(label.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: EthioSpacing.sm - 2),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Timeline Card ─────────────────────────────────────────────────────────────
class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key, required this.day, this.trailing});

  final PlannerDay day;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(EthioSpacing.xl - 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(day.icon, color: scheme.primary),
          ),
          const SizedBox(width: EthioSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.dayLabel,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.secondary)),
                const SizedBox(height: EthioSpacing.xs),
                Text(day.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: EthioSpacing.xs),
                Text(day.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.55))),
                const SizedBox(height: EthioSpacing.sm + 2),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 16, color: scheme.tertiary),
                    const SizedBox(width: EthioSpacing.sm - 2),
                    Text(day.timeRange,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: EthioSpacing.lg),
                    Icon(Icons.payments_outlined,
                        size: 16, color: scheme.secondary),
                    const SizedBox(width: EthioSpacing.sm - 2),
                    Text(day.cost,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: EthioSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ── Map Preview ───────────────────────────────────────────────────────────────
class MapPreview extends StatelessWidget {
  const MapPreview({super.key, this.height = 430});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: height,
        child: CustomPaint(
          painter: OfflineMapPainter(),
          child: Stack(
            children: [
              const Positioned.fill(child: _MapGridOverlay()),
              ..._defaultMapPins.map(
                (pin) => Align(
                  alignment: pin.position,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: _MapPinWidget(pin: pin),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapGridOverlay extends StatelessWidget {
  const _MapGridOverlay();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerLowest,
            scheme.surfaceContainerLow.withValues(alpha: 0.92),
          ],
        ),
      ),
    );
  }
}

class _MapPinWidget extends StatelessWidget {
  const _MapPinWidget({required this.pin});

  final MapPin pin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: pin.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: pin.color.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(pin.icon, color: Colors.white),
        ),
        Container(width: 2, height: 14, color: pin.color),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EthioSpacing.md, vertical: EthioSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(pin.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ── Map Painter ───────────────────────────────────────────────────────────────
class OfflineMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = EthioColors.surfaceContainerLow;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final gridPaint = Paint()
      ..color = EthioColors.outline.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const gridStep = 38.0;
    for (double x = 0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = EthioColors.outline.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.36)
      ..quadraticBezierTo(size.width * 0.32, size.height * 0.32,
          size.width * 0.47, size.height * 0.58)
      ..quadraticBezierTo(
          size.width * 0.60, size.height * 0.76, size.width, size.height * 0.56);
    canvas.drawPath(path, roadPaint);

    final trailPaint = Paint()
      ..color = EthioColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final trailPath = Path()
      ..moveTo(size.width * 0.74, 0)
      ..lineTo(size.width * 0.74, size.height);
    canvas.drawPath(trailPath, trailPaint);

    final circlePaint = Paint()
      ..color = EthioColors.secondaryContainer.withValues(alpha: 0.5);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.55),
        math.min(size.width, size.height) * 0.18,
        circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _defaultMapPins = <MapPin>[
  MapPin(
    name: 'Lali Hotel',
    position: Alignment(-0.35, -0.2),
    icon: Icons.hotel_outlined,
    color: EthioColors.primary,
  ),
  MapPin(
    name: 'Fasil Ghebbi',
    position: Alignment(0.35, 0.35),
    icon: Icons.castle_outlined,
    color: EthioColors.secondary,
  ),
  MapPin(
    name: 'Coffee Stop',
    position: Alignment(0.05, 0.1),
    icon: Icons.coffee_outlined,
    color: EthioColors.tertiary,
  ),
];
