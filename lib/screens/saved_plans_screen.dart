import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_scope.dart';

class SavedPlansScreen extends StatelessWidget {
  const SavedPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);
    final plans = state.savedAiPlans;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 84, 20, 24),
      children: [
        Text('Saved Plans', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Reopen your AI itineraries and track progress as you travel.',
          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 20),
        if (plans.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 44, color: scheme.primary),
                const SizedBox(height: 12),
                const Text('No saved AI plans yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 6),
                Text(
                  'Generate a trip in AI Planner and tap Save to keep it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.65)),
                ),
              ],
            ),
          )
        else
          ...plans.map((plan) => _SavedPlanCard(plan: plan)),
      ],
    );
  }
}

class _SavedPlanCard extends StatelessWidget {
  const _SavedPlanCard({required this.plan});

  final SavedAiTripPlan plan;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.read(context);
    final scheme = Theme.of(context).colorScheme;
    final total = plan.tasks.length;
    final complete = plan.completedTasks;
    final progress = total == 0 ? 0.0 : complete / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.createdAt.day}/${plan.createdAt.month}/${plan.createdAt.year}  -  $complete/$total completed',
                      style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.65), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => state.deleteSavedPlan(plan.id),
                icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                tooltip: 'Delete plan',
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 14),
          if (plan.tasks.isEmpty)
            Text(
              'No checklist items parsed. You can still review full sections below.',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
            )
          else ...[
            if (progress == 1.0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    const Text('Trip completed! Awesome job.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ...plan.tasks.map((task) {
              final isDone = task.completed;
              return GestureDetector(
                onTap: () => state.toggleSavedPlanTask(planId: plan.id, taskId: task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDone ? scheme.surfaceContainerHigh.withValues(alpha: 0.5) : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDone ? scheme.outline.withValues(alpha: 0.1) : scheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDone ? scheme.primary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone ? scheme.primary : scheme.outline.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: isDone ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isDone ? FontWeight.w500 : FontWeight.w700,
                            color: isDone ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onSurface,
                            decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                          child: Text(task.label),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text('View full plan details', style: TextStyle(fontWeight: FontWeight.w700)),
            children: plan.sections
                .map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title, style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary)),
                        const SizedBox(height: 6),
                        Text(section.body, style: TextStyle(height: 1.45, color: scheme.onSurface.withValues(alpha: 0.82))),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
