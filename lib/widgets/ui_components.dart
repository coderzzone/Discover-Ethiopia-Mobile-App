import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_models.dart';

class EthioColors {
  static const Color background = Color(0xFFFBF8F2);
  static const Color surface = Color(0xFFF4EEE4);
  static const Color surfaceContainer = Color(0xFFF0E9DD);
  static const Color surfaceContainerHigh = Color(0xFFE8DFD1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8F3EB);
  static const Color primary = Color(0xFFA5542A);
  static const Color primaryContainer = Color(0xFFF1D8CA);
  static const Color onPrimaryContainer = Color(0xFF6C310F);
  static const Color secondary = Color(0xFF476B4E);
  static const Color secondaryContainer = Color(0xFFE0EFD9);
  static const Color onSecondaryContainer = Color(0xFF35523A);
  static const Color tertiary = Color(0xFF7E6400);
  static const Color tertiaryContainer = Color(0xFFF2E3AA);
  static const Color onTertiaryContainer = Color(0xFF594500);
  static const Color ink = Color(0xFF1B1C19);
  static const Color mutedInk = Color(0xFF6B625A);
  static const Color outline = Color(0xFF8A7A71);
  static const Color error = Color(0xFFBA1A1A);
}

class OfflineChip extends StatelessWidget {
  const OfflineChip({
    super.key,
    required this.label,
    this.color = EthioColors.secondary,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 15, color: color),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: EthioColors.mutedInk),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: EthioColors.primary,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

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
    final background = selected ? color : EthioColors.surfaceContainerLowest;
    final foreground = selected ? Colors.white : EthioColors.ink;
    final borderColor = selected ? Colors.transparent : color.withValues(alpha: 0.18);
    return ActionChip(
      onPressed: onTap,
      side: BorderSide(color: borderColor),
      backgroundColor: background,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      avatar: Icon(icon, size: 18, color: foreground),
      label: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w700)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

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
              color: EthioColors.surfaceContainerHigh,
              child: const Center(child: Icon(Icons.image_not_supported_rounded, color: EthioColors.mutedInk)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
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
                    icon: Icons.location_on, // Replaced dynamic icon since we removed it from Destination
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
                  child: Icon(Icons.bookmark_border_rounded, color: destination.accent, size: compact ? 18 : 22),
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
                const SizedBox(height: 6),
                Text(
                  destination.summary,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: compact ? 13 : 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
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
                color: EthioColors.ink.withValues(alpha: 0.06),
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

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = EthioColors.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 18),
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EthioColors.mutedInk)),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key, required this.day, this.trailing});

  final PlannerDay day;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: EthioColors.primaryContainer.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(day.icon, color: EthioColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.dayLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EthioColors.secondary)),
                const SizedBox(height: 4),
                Text(day.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(day.subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: EthioColors.mutedInk)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: EthioColors.tertiary),
                    const SizedBox(width: 6),
                    Text(day.timeRange, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    Icon(Icons.payments_outlined, size: 16, color: EthioColors.secondary),
                    const SizedBox(width: 6),
                    Text(day.cost, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EthioColors.surfaceContainerLowest,
            EthioColors.surfaceContainerLow.withValues(alpha: 0.92),
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
                color: pin.color.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(pin.icon, color: Colors.white),
        ),
        Container(width: 2, height: 14, color: pin.color),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EthioColors.outline.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: EthioColors.ink.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(pin.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class OfflineMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = EthioColors.surfaceContainerLow;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final gridPaint = Paint()
      ..color = EthioColors.outline.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    const gridStep = 38.0;
    for (double x = 0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = EthioColors.outline.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.36)
      ..quadraticBezierTo(size.width * 0.32, size.height * 0.32, size.width * 0.47, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.60, size.height * 0.76, size.width, size.height * 0.56);
    canvas.drawPath(path, roadPaint);

    final trailPaint = Paint()
      ..color = EthioColors.primary.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final trailPath = Path()
      ..moveTo(size.width * 0.74, 0)
      ..lineTo(size.width * 0.74, size.height);
    canvas.drawPath(trailPath, trailPaint);

    final circlePaint = Paint()..color = EthioColors.secondaryContainer.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), math.min(size.width, size.height) * 0.18, circlePaint);
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
