import 'package:flutter/material.dart';

import '../models/app_models.dart';

class BookingDemoScreen extends StatelessWidget {
  const BookingDemoScreen({super.key, required this.service});

  final DirectoryService service;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Demo Booking', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              service.subtitle,
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.72), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            _Field(label: 'Full name', value: 'Demo User'),
            const SizedBox(height: 12),
            _Field(label: 'Phone', value: '+251 911 000 000'),
            const SizedBox(height: 12),
            _Field(label: 'Date', value: 'May 10, 2026'),
            const SizedBox(height: 12),
            _Field(label: 'Guests', value: '2'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Demo booking submitted for ${service.name}')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: service.brandColor,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Submit Demo Booking', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.72), fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
